class AddLoginLockToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :failed_attempts, :integer, default: 0
    add_column :users, :locked_at, :datetime
    add_column :users, :unlock_token, :string
  end
end
