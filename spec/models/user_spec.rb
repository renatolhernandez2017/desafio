require "rails_helper"

RSpec.describe User, type: :model do
  describe "validações" do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(255) }

    it { should validate_presence_of(:username) }
    it { should validate_length_of(:username).is_at_least(5).is_at_most(50) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should allow_value("nome_123").for(:username) }
    it { should_not allow_value("nome!@#").for(:username) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("teste@email.com").for(:email) }
    it { should_not allow_value("invalido").for(:email) }

    context "validação de senha" do
      it "valida presença e comprimento mínimo" do
        user = build(:user, password: "curta", password_confirmation: "curta")
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("é muito curto (mínimo: 20 caracteres)")
      end
    end
  end

  describe "métodos de conta bloqueada" do
    let(:user) { create(:user, failed_attempts: 0, locked_at: nil) }

    describe "#locked?" do
      it "retorna false se nunca foi bloqueado" do
        expect(user.locked?).to be false
      end

      it "retorna true se bloqueado dentro do tempo limite" do
        user.update!(locked_at: 10.minutes.ago)
        expect(user.locked?).to be true
      end

      it "retorna false se o bloqueio expirou" do
        user.update!(locked_at: 2.hours.ago)
        expect(user.locked?).to be false
      end
    end

    describe "#increment_failed_attempts!" do
      it "incrementa tentativas e bloqueia após limite" do
        (User::MAX_FAILED_ATTEMPTS - 1).times { user.increment_failed_attempts! }

        expect(user.failed_attempts).to eq(User::MAX_FAILED_ATTEMPTS - 1)
        expect(user.locked?).to be false

        user.increment_failed_attempts!

        expect(user.failed_attempts).to eq(User::MAX_FAILED_ATTEMPTS)
        expect(user.locked?).to be true
        expect(user.unlock_token).to be_present
      end
    end

    describe "#reset_failed_attempts!" do
      it "reseta tentativas para zero" do
        user.update!(failed_attempts: 3)
        user.reset_failed_attempts!
        expect(user.failed_attempts).to eq(0)
      end
    end

    describe "#lock_account!" do
      it "define locked_at e unlock_token" do
        user.lock_account!
        expect(user.locked_at).to be_within(2.seconds).of(Time.current)
        expect(user.unlock_token).to be_present
      end
    end

    describe "#unlock_account!" do
      it "limpa dados de bloqueio" do
        user.update!(failed_attempts: 5, locked_at: Time.current, unlock_token: "abc123")
        user.unlock_account!

        expect(user.failed_attempts).to eq(0)
        expect(user.locked_at).to be_nil
        expect(user.unlock_token).to be_nil
      end
    end
  end
end
