defmodule Airlink.Repo.Migrations.CreateHotspots do
  use Ecto.Migration

  def change do
    create table(:hotspots) do
      add :name, :string, null: false
      add :description, :string
      add :bridge_name, :string
      add :landmark, :string
      add :router_id, :uuid, null: false
      add :uuid, :uuid, null: false
      add :company_id, :uuid, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:hotspots, [:name])
    create index(:hotspots, [:latitude, :longitude])
    create index(:hotspots, [:uuid])
    create index(:hotspots, :company_id)
    create index(:hotspots, [:router_id])
  end
end
