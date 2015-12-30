# encoding: UTF-8
require 'spec_helper'

# To test:
# BUNDLE_GEMFILE='gemfiles/active_record_edge_ransack.gemfile' bundle install
# BUNDLE_GEMFILE='gemfiles/active_record_edge_ransack.gemfile' bundle exec rspec ./spec/requests/ransack_spec.rb

# controllers
class UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q])
    @users = @q.result.page(params[:page])

    render :inline => <<-ERB
<%= @users.map(&:name).join("\n") %>
<%= paginate @users %>
ERB
  end
end

feature 'Users' do
  background do
    1.upto(100) {|i| User.create! :name => "user#{'%03d' % i}" }
  end
  scenario 'navigating by pagination links' do
    visit users_path("q[name_cont]" => "user", commit: "Search")

    within 'nav.pagination' do
      within 'span.next' do
        find('a')['href'].should have_content 'page=2'
        find('a')['href'].should_not have_content 'ActionController'
        find('a')['href'].should_not have_content 'Parameters'
        find('a')['href'].should have_content 'name_cont'
      end
    end

  end
end
