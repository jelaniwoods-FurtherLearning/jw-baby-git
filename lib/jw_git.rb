
require "jw_git/version"

module JwGit
  require "jw_git/diff"
  require "jw_git/string"
  require "sinatra"
  require "date"
  require "git"
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  class Server < Sinatra::Base
    get '/' do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      logs = g.log
      list = []
      logs.each do |commit|
        # line = commit.sha + " " + commit.author.name + " " +
        # commit.date.strftime("%a, %d %b %Y, %H:%M %z") + " " + commit.message
        sha = commit.sha.slice(0..7)
        commit_date = Date.parse commit.date
        line = " * " + sha + " - " + commit_date + " (" + time_ago_in_words(commit_date)
         + ") " + "\n\t| " + commit.message 
        list.push line
      end
      list.join("<br>")
      #sha = commit.sha.slice(0..7)
      # commit_date = Date.parse commit.date
      # strftime("%a, %d %b %Y, %H:%M %z") -> time_ago_in_words(commit_date)
      # * 76eff73 - Wed, 11 Mar 2020 19:58:21 +0000 (13 days ago) (HEAD -> current_branch)
      #  | blease - Jelani Woods

      # " * " + sha + " - " + commit_date + " (" + time_ago_in_words(commit_date) + ") " + "\n\t| " + commit.message 
    end
    
    get "/status" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      # Just need the file names
      @changed_files = g.status.changed.keys
      @deleted_files = g.status.added.keys
      @untracked_files = g.status.untracked.keys
      @added_files = g.status.deleted.keys
      # TODO shelling out status is different than g.status
      @status = `git status`
      @current_branch = g.branches.select(&:current).first
      @diff = g.diff
      @diff = Diff.diff_to_html(g.diff.to_s)
    
      @branches = g.branches.map(&:full)

      logs = g.log
      @list = []
      logs.each do |commit|
        sha = commit.sha.slice(0..7)
        commit_date = Date.parse commit.date
        line = " * " + sha + " - " + commit_date + " (" + time_ago_in_words(commit_date)
         + ") " + "\n\t| " + commit.message 
        list.push line
      end
      erb :status
    end
    
    post "/commit" do
      title = params[:title]
      description = params[:description]
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
    
    post "/checkout" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      name = params[:branch_name]
      g.branch(name).checkout
      redirect to("/status")
    end
  end
end
