require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'user登録のテスト' do
    context "nameカラム" do
      it "氏名が無ければ登録できない" do
        expect(build(:user, name: '')).to be_invalid
      end
      it "氏名があればバリデーションに通る" do
        expect(build(:user, name: 'name')).to be_valid
      end

      it "氏名が20文字を超えると登録できない" do
        expect(build(:user, name: 'a' * 21)).to be_invalid
      end
      it "氏名が20文字以内であればバリデーションに通る" do
        expect(build(:user, name: 'a' * 20)).to be_valid
      end
    end

    context "emailカラム" do
      it "メールアドレスが無ければ登録できない" do
        expect(build(:user, email: '')).to be_invalid
      end
      it "メールアドレスがあればバリデーションに通る" do
        expect(build(:user, email: 'sample1@email.com')).to be_valid
      end

      it "メールアドレスが100文字を超えると登録できない" do
        expect(build(:user, email: ('a' * 101) + '@email.com')).to be_invalid
      end
      it "メールアドレスが100文字以内であればバリデーションに通る" do
        expect(build(:user, email: ('a' * 90) + '@email.com')).to be_valid
      end

      it "メールアドレスのフォーマットが不適切な場合、登録できない" do
        expect(build(:user, email: 'invalid_email')).to be_invalid
      end
      it "メールアドレスのフォーマットが適切であればバリデーションに通る" do
        expect(build(:user, email: 'valid@email.com')).to be_valid
      end

      it "同じメールアドレスを持つユーザーが既に存在する場合、登録できない" do
        # 既に存在するユーザーを作成
        existing_user = create(:user, email: 'test-1@email.com')
        # 新しいユーザーを同じメールアドレスで作成
        user1 = build(:user, email: 'test-1@email.com')
        expect(user1).to be_invalid
      end
      it "既に存在するユーザーのメールアドレスと異なればバリデーションに通る" do
        # 既に存在するユーザーを作成
        existing_user = create(:user, email: 'test-1@email.com')
        # 新しいユーザーを違うメールアドレスで作成
        user2 = build(:user, email: 'test-2@email.com')
        expect(user2).to be_valid
      end
    end

    context "passwordカラム、password_confirmationカラム" do
      it "パスワード、パスワード（確認用）が無ければ登録できない" do
        expect(build(:user, password: '', password_confirmation: '')).to be_invalid
      end
      it "パスワード、パスワード（確認用）があればバリデーションに通る" do
        expect(build(:user, password: 'password', password_confirmation: 'password')).to be_valid
      end

      it "パスワード、パスワード（確認用）が8文字未満の場合、登録できない" do
        expect(build(:user, password: 'a' * 7, password_confirmation: 'a' * 7)).to be_invalid
      end
      it "パスワード、パスワード（確認用）が8文字以上であればバリデーションに通る" do
        expect(build(:user, password: 'a' * 8, password_confirmation: 'a' * 8)).to be_valid
      end

      it "パスワード、パスワード（確認用）が30文字を超える場合、登録できない" do
        expect(build(:user, password: 'a' * 31, password_confirmation: 'a' * 31)).to be_invalid
      end
      it "パスワード、パスワード（確認用）が30文字以内であればバリデーションに通る" do
        expect(build(:user, password: 'a' * 30, password_confirmation: 'a' * 30)).to be_valid
      end

      it "パスワード、パスワード（確認用）が半角英数（英字は小文字のみ）でなければ登録できない" do
        expect(build(:user, password: 'PASSWORD', password_confirmation: 'PASSWORD')).to be_invalid
      end
      it "パスワード、パスワード（確認用）が半角英数（英字は小文字のみ）であればバリデーションに通る" do
        expect(build(:user, password: 'password', password_confirmation: 'password')).to be_valid
      end

      it "パスワードとパスワード（確認用）が同じでなければ登録できない" do
        expect(build(:user, password: 'password', password_confirmation: 'passward')).to be_invalid
      end
      it "パスワードとパスワード（確認用）が同じであればバリデーションに通る" do
        expect(build(:user, password: 'password', password_confirmation: 'password')).to be_valid
      end
    end

    context "user登録成功するテスト" do
      it "すべてのバリデージョンに通っていれば登録できる" do
        user = FactoryBot.build(:user)
        expect(user).to be_valid
      end
    end
  end

  describe 'project_leader? メソッドのテスト' do
    let(:user) { create(:user) }
    let(:project) { create(:project) }

    context 'ユーザーがプロジェクトリーダーの場合' do
      before do
        project.update(leader_id: user.id) # ユーザーをプロジェクトリーダーに設定
      end
      it 'trueを返す' do
        expect(user.project_leader?).to be true
      end
    end

    context 'ユーザーがプロジェクトリーダーではない場合' do
      it 'falseを返す' do
        expect(user.project_leader?).to be false
      end
    end
  end

  describe 'send_invite_email メソッドのテスト' do
    let(:user) { create(:user) }
    let(:token) { '12345' }
    let(:name) { 'テストユーザー' }
    let(:password) { 'password' }

    it '招待メールを送信する' do
      expect(UserMailer).to receive(:invitation).with(user, token, name, password).and_call_original
      expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
      user.send_invite_email(token, name, password)
    end
  end

  describe 'update_without_current_password メソッドのテスト' do
    let(:user) { create(:user, password: "oldpassword", password_confirmation: "oldpassword") }

    context 'ユーザー情報更新時、新しいメールアドレスを入力し、パスワードは未入力の場合' do
      let(:params) { { email: 'new-address@email.com', current_password: 'oldpassword' } }

      it 'パスワードは変わらず、メールアドレスのみ更新される' do
        expect(user.update_without_current_password(params)).to be_truthy
        expect(user.reload.email).to eq('new-address@email.com')
      end
    end

    context 'パスワードとパスワード（確認用）が未入力の場合' do
      let(:params) { { email: 'new-address@email.com', password: '', password_confirmation: '', current_password: 'oldpassword' } }

      it 'パスワードは変わらず、メールアドレスのみ更新される' do
        old_encrypted_password = user.encrypted_password
        user.update_without_current_password(params)
        expect(user.reload.email).to eq('new-address@email.com')
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end
    end
  end

  describe 'コールバックのテスト' do
    it '保存する前にメールアドレスを小文字に変換する' do
      user = build(:user, email: 'SAMPLE@EMAIL.COM')

      # 保存前のemailが大文字であることを確認
      expect(user.email).to eq('SAMPLE@EMAIL.COM')
      user.save

      # データベースに保存された後のemailが小文字に変換されていることを確認
      expect(user.reload.email).to eq('sample@email.com')
    end
  end
end
