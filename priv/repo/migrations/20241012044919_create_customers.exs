defmodule Airlink.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :uuid, :uuid, null: false
      add :username, :string, null: false
      add :password_hash, :string
      add :status, :string, null: false
      add :company_id, :uuid, null: false
      add :first_name, :string
      add :last_name, :string
      add :email, :string
      add :phone_number, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:customers, [:company_id, :username])
    create index(:customers, [:company_id])
    create index(:customers, :username)
    create index(:customers, :uuid)
  end
end
