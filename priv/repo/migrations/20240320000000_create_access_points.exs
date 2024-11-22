defmodule Airlink.Repo.Migrations.CreateAccessPoints do
  use Ecto.Migration

  def change do
    create table(:access_points) do
      add :landmark, :string, null: false
      add :mac_address, :string, null: false
      add :name, :string, null: false
      add :type, :string, null: false
      add :description, :text
      add :company_id, :uuid, null: false
      add :uuid, :uuid, null: false
      add :status, :string, default: "Offline"
      add :last_seen, :utc_datetime
      # in minutes
      add :offline_after, :integer, default: 10

      timestamps(type: :utc_datetime)
    end

    create index(:access_points, [:company_id])
    create unique_index(:access_points, [:mac_address, :company_id])
    create unique_index(:access_points, [:uuid])
  end
end
