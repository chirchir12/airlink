defmodule Airlink.Repo.Migrations.AddColumnActivatedAt do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :activated_at, :utc_datetime
    end
  end
end
