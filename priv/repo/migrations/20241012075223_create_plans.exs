defmodule Airlink.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :uuid, :uuid, null: false
      add :name, :string, null: false
      add :description, :string

      add :duration, :integer, null: false
      add :time_unit, :string, null: false

      add :upload_speed, :integer, null: false
      add :download_speed, :integer, null: false
      add :speed_unit, :string, null: false

      add :bundle_size, :integer, null: false
      add :bundle_unit, :string, null: false

      add :price, :decimal, null: false
      add :currency, :string, null: false
      add :company_id, :uuid, null: false
      add :hotspot_id, references(:hotspots, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:plans, [:company_id])
    create index(:plans, [:hotspot_id])
    create unique_index(:plans, [:uuid])
    create unique_index(:plans, [:name, :company_uuid])
  end
end
