require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  fixtures :customers
  def setup
    @request.with_subdomain('cit')
    @user = User.make(:admin)
    sign_in @user
    @request.session[:user_id] = @user.id
    @user.company.create_default_statuses
    3.times {
      project = Project.make(:customer => @user.customer, :company => @user.company)
      project.users << @user
    }
  end

  context 'a normal milestone' do
    should "render get_milestones" do
      @task = Task.make(:company => @user.company, :project => @user.projects.first)
      get :get_milestones, :project_id => @task.project.id
      assert_response :success
    end

    should "be able to create milestone" do
      get :new, :project_id => @user.projects.first.id
      assert_response :success

      post :create, :milestone => {:name => "test", :due_at => Time.now.ago(-3.days), :description => "test milestone", :project_id => Project.first.id}
      assert_response 302
    end

    should "be able to update milestone" do
      project = @user.projects.first
      milestone = project.milestones.create!(:name => "test", :due_at => Time.now.ago(-3.days), :description => "test milestone", :company => @user.company)

      get :edit, :id => milestone.id
      assert_response :success

      put :update, :id => milestone.id, :milestone => {:name => "test2"}
      assert_response 302
    end

    should "be able to destroy milestone" do
      project = @user.projects.first
      milestone = project.milestones.create!(:name => "test", :due_at => Time.now.ago(-3.days), :description => "test milestone", :company => @user.company)

      delete :destroy, :id => milestone.id
      assert_redirected_to edit_project_path(project)
    end

    should "be able to complete milestone" do
      project = @user.projects.first
      milestone = project.milestones.create!(:name => "test", :due_at => Time.now.ago(-3.days), :description => "test milestone", :company => @user.company)

      assert !milestone.closed?
      post :complete, :id => milestone.id
      assert milestone.reload.closed?
    end

    should "be able to revert milestone" do
      project = @user.projects.first
      milestone = project.milestones.create!(:name => "test", :due_at => Time.now.ago(-3.days), :description => "test milestone", :company => @user.company, :completed_at => Time.now)

      assert milestone.closed?
      post :revert, :id => milestone.id
      assert !milestone.reload.closed?
    end
  end
end
