require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Locale Helpers" do
  Dir[File.expand_path("../../lib/padrino-helpers/locale/*.yml", __FILE__)].each do |file|
    base_original = YAML.load_file(file)
    name = File.basename(file, '.yml')
    should "should have correct locale for #{name}" do
      base = base_original[name]['number']['format']
      assert !base['separator'].nil?
      assert !base['delimiter'].nil?
      assert !base['precision'].nil?
      base = base_original[name]['number']['currency']['format']
      assert !base['format'].nil?
      assert !base['unit'].nil?
      assert !base['separator'].nil?
      assert !base['delimiter'].nil?
      assert !base['precision'].nil?
    end
  end
end
