Given /^a simple 'where' query$/ do
  @query = Middleman::Sitemap::Queryable::Query.new({}).where(:foo => 'bar')
end

When /^I chain a where clause onto that query$/ do
  @new_query = @query.where(:baz => 'foo')
end

Then /^the original query should remain unchanged$/ do
  @query.opts({}).should_not eql @new_query.opts({})
end

Then /^should initialize with an attribute and an operator$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :author, :operator => 'equal'
  :author.should == selector.attribute
  'equal'.should == selector.operator
end

Then /^should raise an exception if the operator is not supported$/ do
  expect {
    selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :author, :operator => 'zomg'
  }.to raise_error(::Middleman::Sitemap::Queryable::OperatorNotSupportedError)
end

Then /^should limit the documents to the number specified$/ do
  @server_inst.sitemap.order_by(:id).limit(2).all.map { |r| r.raw_data[:id] }.sort.should == [1,2].sort
end

Then /^should offset the documents by the number specified$/ do
  @server_inst.sitemap.order_by(:id).offset(2).all.map { |r| r.raw_data[:id] }.sort.should == [3,4,5].sort
end

Then /^should support offset and limit at the same time$/ do
  @server_inst.sitemap.order_by(:id).offset(1).limit(2).all.map { |r| r.raw_data[:id] }.sort.should == [2,3].sort
end

Then /^should not freak out about an offset higher than the document count$/ do
  @server_inst.sitemap.order_by(:id).offset(5).all.should == []
end

Then /^should return the right documents$/ do
  documents = @server_inst.sitemap.resources.select { |r| !r.raw_data.empty? }
  document_1 = documents[0]
  document_2 = documents[1]

  found_document = @server_inst.sitemap.where(:title => document_1.raw_data[:title]).first
  document_1.should == found_document
  
  found_document = @server_inst.sitemap.where(:title => document_2.raw_data[:title]).first
  document_2.should == found_document
end

Then /^should be chainable$/ do
  documents = @server_inst.sitemap.resources.select { |r| !r.raw_data.empty? }
  document_1 = documents[0]

  document_proxy = @server_inst.sitemap.where(:title => document_1.raw_data[:title])
  document_proxy.where(:id => document_1.raw_data[:id])
  document_1.should == document_proxy.first
end

Then /^should not be confused by attributes not present in all documents$/ do
  result = @server_inst.sitemap.where(:seldom_attribute => 'is seldom').all
  result.map { |r| r.raw_data[:id] }.should == [4]
end

Then /^with a gt operator should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'gt'
  found_documents = @server_inst.sitemap.where(selector => 2).all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [5,3,4].sort
end

Then /^with a gte operator should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'gte'
  found_documents = @server_inst.sitemap.where(selector => 2).all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [2,5,3,4].sort
end

Then /^with an in operator should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'in'
  found_documents = @server_inst.sitemap.where(selector => [2,3]).all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [2,3].sort
end

Then /^with an lt operator should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'lt'
  found_documents = @server_inst.sitemap.where(selector => 2).all
  found_documents.map { |r| r.raw_data[:id] }.should == [1]
end

Then /^with an lte operator should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'lte'
  found_documents = @server_inst.sitemap.where(selector => 2).all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [1,2].sort
end

Then /^with an include operator include should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :tags, :operator => 'include'
  found_documents = @server_inst.sitemap.where(selector => 'ruby').all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [1,2].sort
end

Then /^with mixed operators should return the right documents$/ do
  in_selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'in'
  gt_selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'gt'
  documents_proxy = @server_inst.sitemap.where(in_selector => [2,3])
  found_documents = documents_proxy.where(gt_selector => 2).all
  found_documents.map { |r| r.raw_data[:id] }.should == [3]
end

Then /^using multiple constrains in one where should return the right documents$/ do
  selector = ::Middleman::Sitemap::Queryable::Selector.new :attribute => :id, :operator => 'lte'
  found_documents = @server_inst.sitemap.where(selector => 2, :status => :published).all
  found_documents.map { |r| r.raw_data[:id] }.sort.should == [1,2].sort
end

Then /^should support ordering by attribute ascending$/ do
  found_documents = @server_inst.sitemap.order_by(:title => :asc).all
  found_documents.map { |r| r.raw_data[:id] }.should == [2,3,1,5,4]
end

Then /^should support ordering by attribute descending$/ do
  found_documents = @server_inst.sitemap.order_by(:title => :desc).all
  found_documents.map { |r| r.raw_data[:id] }.should == [4,5,1,3,2]
end

Then /^should order by attribute ascending by default$/ do
  found_documents = @server_inst.sitemap.order_by(:title).all
  found_documents.map { |r| r.raw_data[:id] }.should == [2,3,1,5,4]
end

Then /^should exclude documents that do not own the attribute$/ do
  found_documents = @server_inst.sitemap.order_by(:status).all
  found_documents.map { |r| r.raw_data[:id] }.to_set.should == [1,2].to_set
end
