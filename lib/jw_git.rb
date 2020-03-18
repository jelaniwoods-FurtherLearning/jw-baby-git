
require "jw_git/version"

module JwGit
  require "jw_git/diff"
  require "jw_git/string"
  require 'sinatra'
  require 'git'
  class Server < Sinatra::Base
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
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      g.config('user.name')
      changed_files = g.status.changed
      untracked_files = g.status.untracked
      # TODO shelling out status is different than g.status
      @status = `git status`
      # @wild = g.status.pretty
      @wild = ""
      @current_branch = g.branches.select(&:current).first
      @diff = g.diff
      @diff = Diff.diff_to_html(g.diff.to_s)
    
      @branches = g.branches.map(&:full)
      erb :status
    end
    
    post "/commit" do
      title = params[:title]
      description = params[:description]
      p title
      puts "------"
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      g.add(:all => true)  
      g.commit(title)
      redirect to("/status")
    end
    
    get "/stash" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      g.add(:all=>true)
      stash_count = Git::Stashes.new(g).count
      Git::Stash.new(g, "Stash #{stash_count}")
      redirect to("/status")
    end
  end
end
