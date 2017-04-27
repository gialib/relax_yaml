defmodule RelaxYamlTest do
  use ExUnit.Case
  doctest RelaxYaml

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "yaml OK" do
    assert RelaxYaml.encode!(%{image_uuids: [], user_ids: []}, atoms: true) == ":image_uuids: []\n:user_ids: []\n"

    assert RelaxYaml.encode!(%{address: :null, uuids: [], names: [:happy]}, atoms: true) ==
      ":address: :null\n:names:\n  - :happy\n:uuids: []\n"
    assert RelaxYaml.decode!("---\n:a: :abc\n", atoms: true) == %{a: :abc}

    assert RelaxYaml.encode!(%{a: :abc, b: [:a, :b]}, atoms: true) ==
      ":a: :abc\n:b:\n  - :a\n  - :b\n"
    assert RelaxYaml.decode!(":a: :abc\n:b:\n  - :a\n  - :b\n", atoms: true) == %{a: :abc, b: [:a, :b]}

    assert RelaxYaml.encode!(
      %{
        title: %{short: "哈喽", lang: "不错哈，哈喽"},
        users: [%{name: "happy"}, %{name: "jack"}],
        count: 1024
      }, atoms: false
    ) == "count: 1024\ntitle:\n  lang: \"不错哈，哈喽\"\n  short: \"哈喽\"\nusers:\n  -\n    name: \"happy\"\n  -\n    name: \"jack\"\n"

    assert RelaxYaml.encode!(
      %{
        title: %{short: "哈喽", lang: "不错哈，哈喽"},
        users: [%{name: "happy"}, %{name: "jack"}],
        count: 1024
      }, atoms: true
    ) == ":count: 1024\n:title:\n  :lang: \"不错哈，哈喽\"\n  :short: \"哈喽\"\n:users:\n  -\n    :name: \"happy\"\n  -\n    :name: \"jack\"\n"

    assert RelaxYaml.decode!(
      ":count: 1024\n:title:\n  :lang: \"不错哈，哈喽\"\n  :short: \"哈喽\"\n:users:\n  -\n    :name: \"happy\"\n  -\n    :name: \"jack\"\n",
      atoms: true
    ) == %{
      title: %{short: "哈喽", lang: "不错哈，哈喽"},
      users: [%{name: "happy"}, %{name: "jack"}],
      count: 1024
    }

    assert RelaxYaml.encode!(
      %{
        title: %{short: "哈喽", lang: "不错哈，哈喽"},
        users: [%{name: "happy"}, %{name: "jack"}],
        count: 1024
      }
    ) == "count: 1024\ntitle:\n  lang: \"不错哈，哈喽\"\n  short: \"哈喽\"\nusers:\n  -\n    name: \"happy\"\n  -\n    name: \"jack\"\n"

    assert RelaxYaml.decode!(
      "count: 1024\ntitle:\n  lang: \"不错哈，哈喽\"\n  short: \"哈喽\"\nusers:\n  -\n    name: \"happy\"\n  -\n    name: \"jack\"\n"
    ) == %{
      "count" => 1024,
      "title" => %{
        "lang" => "不错哈，哈喽", "short" => "哈喽"
      },
      "users" => [%{"name" => "happy"}, %{"name" => "jack"}]
    }
  end

end
