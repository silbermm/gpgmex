defmodule GPG.Case do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup _ do
    # If we don't define any expectations, call the real implementation of GPG.NativeAPI (GPG.NIF)
    Mox.stub_with(GPG.MockNativeAPI, GPG.NIF)
    :ok
  end
end
