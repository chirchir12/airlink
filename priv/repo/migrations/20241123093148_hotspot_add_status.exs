defmodule Airlink.Repo.Migrations.HotspotAddStatus do
  use Ecto.Migration

  def change do
    alter table(:hotspots) do
      add :status, :string, default: "inactive"
    end
  end
end
