defmodule Affable.Repo.Migrations.AddLoadBalancerIndexToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:load_balancer_index, :integer, null: true)
    end
  end
end
