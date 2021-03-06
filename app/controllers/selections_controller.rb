class SelectionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :check_mode_of_operation_for_viewing, only: [:index]
  before_filter :check_mode_of_operation_for_selection, only: [:create, :destroy]

  def index
    if can?(:see, :agenda)
      @top_proposals = Selection.popular.select { |count, proposal| proposal.confirmed? }.take(8)
    end
    if current_user && can?(:make, :selection)
      @proposals = Proposal.available_for_selection_by(current_user)
    end
  end

  def create
    selection = current_user.selections.build(params[:selection])
    if selection.save
      redirect_to selections_path
    else
      redirect_to selections_path, alert: selection.errors.full_messages.to_sentence
    end
  end

  def destroy
    selection = current_user.selections.find(params[:id])
    selection.destroy
    redirect_to selections_path
  end

  private
  def check_mode_of_operation_for_viewing
    unless can?(:see, :selection) || can?(:see, :agenda)
      flash[:alert] = "In #{Vestibule.mode_of_operation.mode} mode you cannot vote for proposals or see the generated agenda."
      redirect_to dashboard_path
    end
  end

  def check_mode_of_operation_for_selection
    unless can?(:make, :selection)
      flash[:alert] = "In #{Vestibule.mode_of_operation.mode} mode you cannot vote for proposals."
      redirect_to dashboard_path
    end
  end
end
