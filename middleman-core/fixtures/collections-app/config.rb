collection :articles,
  where: proc { |resource|
    uri_match resource.url, 'blog/{year}-{month}-{day}-{title}.html'
  }

collection :tags,
  where: proc { |resource|
    resource.data.tags
  },
  group_by: proc { |resource|
    if resource.data.tags.is_a? String
      resource.data.tags.split(',').map(&:strip)
    else
      resource.data.tags
    end
  }