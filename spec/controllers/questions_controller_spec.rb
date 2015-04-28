require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do

# User who asked Question
let(:user1) { create :user }

# User who doesn't asked Question
let(:user2) { create :user }

let(:question) { create :question, user: user1 }

let(:file) { create(:attachment) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 2, user: user1) }
    before { get :index }

    it 'population an array of all Question' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end


  describe 'GET #show' do
    before { get :show, id: question }

    it 'assigns requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end

    it 'assigns new answer for question' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end
  end


  describe 'GET #new' do
    before do
      sign_in_user(user1)
      get :new
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'renders new template' do
      expect(response).to render_template :new
    end
  end


  describe 'GET #edit' do
    before do
      sign_in_user(user1)
      get :edit, id: question
    end

    it 'assigns requested question to @questions' do
      expect(assigns(:question)).to eq question
    end

    it 'redirects to edit view' do
      expect(response).to render_template :edit
    end
  end


  describe 'POST #create' do
    before { sign_in_user(user1) }

    context 'with valid attributes' do
      it 'saves the new question in the database' do
        expect { post :create, question: attributes_for(:question) }.to change(Question, :count).by(1)
      end

      it 'saves the attachment in the database' do
        expect { post :create, question: attributes_for(:question), attachment: file }.to change(Attachment, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, question: attributes_for(:question)
        expect(response).to redirect_to question_path(assigns(:question))
      end

      it 'should have a user' do
        post :create, question: attributes_for(:question)
        expect(assigns(:question).user).to eq subject.current_user
      end

    end

    context 'with invalid attributes' do
      it 'does not save question' do
        expect { post :create, question: attributes_for(:invalid_question) }.to_not change(Question, :count)
      end

      it 'render new view' do
        post :create, question: attributes_for(:invalid_question)
        expect(response).to render_template :new
      end
    end
  end


  describe 'PATCH #update' do
    before { sign_in_user(user1) }

    context 'with valid attributes' do
      it 'Assigns requested question to @question' do
        patch :update, id: question, question: attributes_for(:question), format: :js
        expect(assigns(:question)).to eq question
      end
      it 'Changes question attributes' do
        patch :update, id: question, question: { title: 'new default title', body: 'new default body' }, format: :js
        question.reload
        expect(question.title).to eq 'new default title'
        expect(question.body).to eq 'new default body'
      end
      it 'render update template' do
        patch :update, id: question, question: attributes_for(:question), format: :js
        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      before { patch :update, id: question, question: { title: 'new title', body: nil }, format: :js }

      it 'Does not change question attributes' do
        question.reload
        expect(question.title).to eq question.title
        expect(question.body).to eq question.body
      end

      it 'render update template' do
        expect(response).to render_template :update
      end
    end
  end


  describe 'DELETE #destroy' do
    context 'user try delete his question' do
      before do
        sign_in_user(user1)
        question
      end

      it 'delete the question from the database' do
        expect { delete :destroy, id: question }.to change(Question, :count).by(-1)
      end

      it 'redirect to questions' do
        delete :destroy, id: question
        expect(response).to redirect_to questions_path
      end
    end

    context 'user try delete not his question' do
      before do
        sign_in_user(user2)
        question
      end

      it 'delete the question from the database' do
        expect { delete :destroy, id: question }.to_not change(Question, :count)
      end

      it 'redirect to questions' do
        delete :destroy, id: question
        expect(response).to redirect_to question_path(question)
      end
    end
  end


  describe 'PATCH #like' do
    context 'when auth user tries vote as like for not own question' do
      before do
        sign_in_user(user2)
      end

      it 'saves the new vote in the database' do
        expect { patch :like, id: question, format: :json }.to change(Vote, :count).by(1)
      end

      it 'increases the question value' do
        patch :like, id: question, format: :json
        question.reload
        expect(question.total_votes).to eq 1
      end

      it 'renders OK status' do
        patch :like, id: question, format: :json
        expect(response).to have_http_status(200)
      end
    end

    context 'when auth user tries vote as like for own question' do
      before do
        sign_in_user(user1)
        patch :like, id: question, format: :json
      end

      it 'isn\'t increases the question value' do
        question.reload
        expect(question.total_votes).to eq 0
      end

      it 'renders Forbidden status' do
        expect(response).to have_http_status(403)
      end
    end


    context 'when not auth user tries vote as like for anything question' do
      before { patch :like, id: question, format: :json }

      it 'renders Unauthorized status' do
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PATCH #dislike' do
    context 'when auth user tries vote as dislike for not own question' do
      before do
        sign_in_user(user2)
      end

      it 'saves the new vote in the database' do
        expect { patch :dislike, id: question, format: :json }.to change(Vote, :count).by(1)
      end

      it 'increases the question value' do
        patch :dislike, id: question, format: :json
        question.reload
        expect(question.total_votes).to eq -1
      end

      it 'renders OK status' do
        patch :dislike, id: question, format: :json
        expect(response).to have_http_status(200)
      end
    end

    context 'when auth user tries vote as dislike for own question' do
      before do
        sign_in_user(user1)
        patch :dislike, id: question, format: :json
      end

      it 'isn\'t increases the question value' do
        question.reload
        expect(question.total_votes).to eq 0
      end

      it 'renders Forbidden status' do
        expect(response).to have_http_status(403)
      end
    end


    context 'when not auth user tries vote as dislike for anything question' do
      before { patch :dislike, id: question, format: :json }

      it 'renders Unauthorized status' do
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'PATCH #unvote' do
    let!(:vote) { create(:vote, votable_id: question.id, votable_type: question.class, user: user2, value: 1) }

    context 'when auth user tries unvote for not own question' do
      before do
        sign_in_user(user2)
      end

      it 'saves the new vote in the database' do
        expect { patch :unvote, id: question, format: :json }.to change(Vote, :count).by(-1)
      end

      it 'increases the question value' do
        patch :unvote, id: question, format: :json
        question.reload
        expect(question.total_votes).to eq 0
      end

      it 'renders OK status' do
        patch :unvote, id: question, format: :json
        expect(response).to have_http_status(200)
      end
    end

    context 'when auth user tries vote as dislike for own question' do
      before do
        sign_in_user(user1)
        patch :unvote, id: question, format: :json
      end

      it 'isn\'t increases the question value' do
        question.reload
        expect(question.total_votes).to eq 1
      end

      it 'renders Forbidden status' do
        expect(response).to have_http_status(403)
      end
    end


    context 'when not auth user tries vote as dislike for anything question' do
      before { patch :unvote, id: question, format: :json }

      it 'renders Unauthorized status' do
        expect(response).to have_http_status(401)
      end
    end
  end

end
