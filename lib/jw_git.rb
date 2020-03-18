require "jw_git/version"
require "jw_git/diff"
require "jw_git/string"
require 'sinatra'
require 'git'

module Server
  class JwGit < Sinatra::Base
    get '/' do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      logs = g.log
      list = []
      logs.each do |commit|
        line = commit.sha + " " + commit.author.name + " " +
        commit.date.strftime("%m-%d-%y") + " " + commit.message
        list.push line
      end
      list.join("<br>")
    end
    
    get "/status" do
      working_dir = Dir.pwd
      g = Git.open(working_dir)
      g.config('user.name')
      changed_files = g.status.changed
      untracked_files = g.status.untracked
      puts "\n" * 5
      puts g.status.pretty
      puts "\n" * 5
      @status = `git status`
      # @wild = g.status.pretty
      @wild = ""
      @current_branch = g.branches.select(&:current).first
      @diff = g.diff
      @diff = Diff.diff_to_html(g.diff.to_s)
    
      erb :status
    end
    
    post "/commit" do
      title = params[:title]
      description = params[:description]
      p title
      puts "------"
      working_dir = Dir.pwd
      g = Git.open(working_dir)
      g.add(:all=>true)  
      g.commit(title)
      redirect to("/status")
    end
    
  end
end
