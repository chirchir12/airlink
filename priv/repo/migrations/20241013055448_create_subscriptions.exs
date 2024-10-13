defmodule Airlink.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :customer_id, references(:customers, on_delete: :nothing), null: false
      add :plan_id, references(:plans, on_delete: :nothing), null: false
      add :status, :string, null: false
      add :expires_at, :utc_datetime
      add :company_id, :uuid, null: false
      add :uuid, :uuid, null: false
      add :meta, :map

      timestamps(type: :utc_datetime)
    end

    create index(:subscriptions, [:customer_id])
    create index(:subscriptions, [:plan_id])
    create index(:subscriptions, [:company_id])
  end
end
