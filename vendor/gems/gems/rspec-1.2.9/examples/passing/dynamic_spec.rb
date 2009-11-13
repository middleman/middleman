describe "The square root" do
  (1..10).each do |n|
    it "of #{n*n} should be #{n}" do
      Math.sqrt(n*n).should == n
    end
  end
end
