defmodule AirlinkWeb.CaptiveJSON do
  #!! ONLY USED FOR TESTING
  def show(%{status: status}) do
    %{
      status: status
    }
  end

  def show(%{params: params}) do
    params
  end
end
