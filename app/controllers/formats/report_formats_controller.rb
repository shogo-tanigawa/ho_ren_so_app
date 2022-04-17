class Formats::ReportFormatsController < Formats::BaseFormatController
  # 入力フォーム新規登録アクション
  def create
    @project = Project.find(params[:project_id])
    question = @project.questions.build(create_formats_params)
    if question.save
      flash[:notice] = '入力フォームを新規登録しました。'
    else
      flash[:alert] = '入力フォームの新規登録に失敗しました。'
    end
    redirect_to edit_project_report_format_path(@project)
  end

  # 入力フォーム新規登録用モーダルウインドウ表示アクション
  def new
    @project = Project.find(params[:project_id])
    @position_value =
      if @project.questions.exists?
        @project.questions.last.position + 1
      else
        1
      end
    @form_table_type_value = 'text_field'
    @form_type_symbol = :text_field
    @questions_build_object = @project.questions.build
    @questions_build_object.build_text_field
  end

  # 入力フォーム編集ページ表示アクション
  def edit
    @project = Project.find(params[:project_id])
    @user = User.find(params[:user_id])
    @questions = @project.questions.order(:position)
    @form_number = 0
  end

  # 入力フォーム編集アクション
  def update
    @project = Project.find(params[:project_id])
    params = update_formats_params[:question_attributes]
    params.each do |question_id, items|
      question_object = Question.find(question_id)
      question_object.update(items)
    end
    flash[:notice] = '入力項目のデータを更新しました。'
    redirect_to edit_project_report_format_path(@project)
  end

  # 入力フォーム削除アクション
  def destroy
    @project = Project.find(params[:project_id])
    form = Question.find(params[:question_id])
    if form.destroy
      flash[:notice] = '入力フォームを削除しました。'
    else
      flash[:alert] = '入力フォームの削除に失敗しました。'
    end
    redirect_to edit_project_report_format_path(@project)
  end

  # 入力フォーム新規登録用モーダルウインドウ内のコンテンツを動的に変化させる処理に関連するajaxアクション
  def replacement_input_forms
    @project = Project.find(params[:project_id])
    @position_value =
      if @project.questions.exists?
        @project.questions.last.position + 1
      else
        1
      end
    @questions_build_object = @project.questions.build
    case params[:form_type]
    when 'text_field'
      @questions_build_object.build_text_field
      @form_type_symbol = :text_field
      @form_table_type_value = 'text_field'
    when 'text_area'
      @questions_build_object.build_text_area
      @form_type_symbol = :text_area
      @form_table_type_value = 'text_area'
    when 'date_field'
      @questions_build_object.build_date_field
      @form_type_symbol = :date_field
      @form_table_type_value = 'date_field'
    when 'radio_button'
      @radio_button_build_object = @questions_build_object.build_radio_button
      @form_type_symbol = :radio_button
      @option_strings_build_object = @radio_button_build_object.radio_button_option_strings.build
      @form_option_symbol = :radio_button_option_strings
      @form_table_type_value = 'radio_button'
    when 'check_box'
      @check_box_build_object = @questions_build_object.build_check_box
      @form_type_symbol = :check_box
      @check_box_build_object.check_box_option_strings.build
      @form_option_symbol = :check_box_option_strings
      @form_table_type_value = 'check_box'
    when 'select'
      @select_build_object = @questions_build_object.build_select
      @form_type_symbol = :select
      @select_build_object.select_option_strings.build
      @form_option_symbol = :select_option_strings
      @form_table_type_value = 'select'
    end
  end

  private

  # フォーム新規登録並びに編集用/create
  def create_formats_params
    params.require(:question).permit(:id, :form_table_type, :position,
                                     text_field_attributes: %i[id label_name field_type],
                                     text_area_attributes: %i[id label_name field_type],
                                     date_field_attributes: %i[id label_name field_type],
                                     radio_button_attributes: [:id, :label_name, :field_type, {
                                       radio_button_option_strings_attributes: [%i[id option_string _destroy]]
                                     }],
                                     check_box_attributes: [:id, :label_name, :field_type, {
                                       check_box_option_strings_attributes: [%i[id option_string _destroy]]
                                     }],
                                     select_attributes: [:id, :label_name, :field_type, {
                                       select_option_strings_attributes: [%i[id option_string _destroy]]
                                     }])
  end

  def update_formats_params
    params.permit(question_attributes: [:id, [:id, :form_table_type, :position, :using_flag, {
                    text_field_attributes: %i[id label_name field_type],
                    text_area_attributes: %i[id label_name field_type],
                    date_field_attributes: %i[id label_name field_type],
                    radio_button_attributes: [:id, :label_name, :field_type, {
                      radio_button_option_strings_attributes: %i[id option_string _destroy]
                    }],
                    check_box_attributes: [:id, :label_name, :field_type, {
                      check_box_option_strings_attributes: %i[id option_string _destroy]
                    }],
                    select_attributes: [:id, :label_name, :field_type, {
                      select_option_strings_attributes: %i[id option_string _destroy]
                    }]
                  }]])
  end
end