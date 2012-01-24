require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "Locales" do
  Dir[File.expand_path("../../lib/padrino-core/locale/*.yml", __FILE__)].each do |file|
    base_original = YAML.load_file(file)
    name = File.basename(file, '.yml')
    should "should have correct locale for #{name}" do
      base = base_original[name]['date']['formats']
      assert base['default'].present?
      assert base['short'].present?
      assert base['long'].present?
      assert base['only_day'].present?
      base = base_original[name]['date']
      assert base['day_names'].present?
      assert base['abbr_day_names'].present?
      assert base['month_names'].present?
      assert base['abbr_month_names'].present?
      assert base['order'].present?
    end
  end
end
