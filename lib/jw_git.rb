
require "jw_git/version"

module JwGit
  require "jw_git/diff"
  require "jw_git/string"
  require "sinatra"
  require "date"
  require "git"
  class Server < Sinatra::Base
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper

    get '/' do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      logs = g.log
      list = []
      logs.each do |commit|
        # line = commit.sha + " " + commit.author.name + " " +
        # commit.date.strftime("%a, %d %b %Y, %H:%M %z") + " " + commit.message
        sha = commit.sha.slice(0..7)
        commit_date = commit.date
        line = " * " + sha + " - " + commit.date.strftime("%a, %d %b %Y, %H:%M %z") +
         " (#{time_ago_in_words(commit_date)} ago) " + "<br>&emsp;| " + commit.message 
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

      @statuses = [
        { name: "Changed Files:", file_list: @changed_files },
        { name: "Untracked Files:", file_list: @untracked_files },
        { name: "Deleted Files:", file_list: @deleted_files },
        { name: "Added Files:", file_list: @added_files }
      ]
      
      # TODO shelling out status is different than g.status
      @status = `git status`
      @current_branch = g.branches.select(&:current).first
      @diff = g.diff
      @diff = Diff.diff_to_html(g.diff.to_s)
      last_diff = g.diff(g.log[1], "HEAD").to_s + "\n"
      # @last_diff_html = Diff.last_to_html(last_diff)
      @last_diff_html = last_diff
      @branches = g.branches.local.map(&:full)
      
      logs = g.log
      @last_commit_message = logs.first.message
      @list = []
      logs.each do |commit|
        sha = commit.sha.slice(0..7)
        commit_date = commit.date
        line = " * " + sha + " - " + commit.date.strftime("%a, %d %b %Y, %H:%M %z") +
         " (#{time_ago_in_words(commit_date)}) " + "\n\t| " + commit.message 
        @list.push line
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
    
    post "/branch/checkout" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      p params
      puts "-----"
      name = params[:branch_name]
      g.branch(name).checkout
      redirect to("/status")
    end
    
    delete "/branch/delete" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      name = params[:branch_name]
      g.branch(branch).delete
      redirect to("/status")
    end

    post "/push" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      # TODO push to heroku eventually
      g.push
      redirect to("/status")
    end

    post "/pull" do
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      g = Git.open(working_dir)
      g.pull
      redirect to("/status")
    end
  end
end
