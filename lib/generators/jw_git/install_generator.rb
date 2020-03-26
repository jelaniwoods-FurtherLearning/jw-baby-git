module JwGit
  class InstallGenerator < Rails::Generators::Base
    def modify_config_ru
      
      contents = <<-RUBY.gsub(/^      /, "")
      map '/git' do
        run JwGit::Server
      end
      
      map '/' do
        run Rails.application
      end
      RUBY
      filename = "config.ru"
      match_text = "run Rails.application"
  
      gsub_file filename, match_text, contents
      puts "Setup complete."
    end
  end
end
