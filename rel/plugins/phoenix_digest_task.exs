defmodule Eblox.PhoenixDigestTask do
  use Mix.Releases.Plugin

  def before_assembly(%Release{} = _release, _opts \\ []) do
    info("before assembly!")

    case System.cmd("npm", ["run", "deploy"]) do
      {output, 0} ->
        info(output)
        Mix.Task.run("phx.digest")
        nil

      {output, error_code} ->
        {:error, output, error_code}
    end
  end

  def after_assembly(%Release{} = _release, _opts \\ []) do
    info("after assembly!")
    nil
  end

  def before_package(%Release{} = _release, _opts \\ []) do
    info("before package!")
    nil
  end

  def after_package(%Release{} = _release, _opts \\ []) do
    info("after package!")
    nil
  end

  def after_cleanup(%Release{} = _release, _opts \\ []) do
    info("after cleanup!")
    nil
  end
end
