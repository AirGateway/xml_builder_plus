defmodule XmlBuilderPlusTest do
  use ExUnit.Case
  doctest XmlBuilderPlus

  import XmlBuilderPlus, only: [doc: 2, doc: 3, doc: 4]

  test "doc with two arguments content and using nil as second parameter" do
    assert doc({:person, %{Version: "1"}, [[{:birthdate, nil, [{:day, nil, "15"}, {:month, nil, "12"}, {:year, nil, "1515"}]}]]}, nil) == ~s|<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<person Version=\"1\">\n\t<birthdate>\n\t\t<day>15</day>\n\t\t<month>12</month>\n\t\t<year>1515</year>\n\t</birthdate>\n</person>|
  end
  test "doc with two arguments content and using [] as second parameter" do
    assert doc({:person, %{Version: "1"}, [[{:birthdate, nil, [{:day, nil, "15"}, {:month, nil, "12"}, {:year, nil, "1515"}]}]]}, []) == ~s|<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<person Version=\"1\">\n\t<birthdate>\n\t\t<day>15</day>\n\t\t<month>12</month>\n\t\t<year>1515</year>\n\t</birthdate>\n</person>|
  end
  test "doc with two arguments content and using some data as second parameter" do
    assert doc({:person, %{Version: "1"}, [[{:birthdate, nil, [{:day, nil, "15"}, {:month, nil, "12"}, {:year, nil, "1515"}]}]]}, %{person: "person:"}) == ~s|<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<person:person Version=\"1\">\n\t<person:birthdate>\n\t\t<person:day>15</person:day>\n\t\t<person:month>12</person:month>\n\t\t<person:year>1515</person:year>\n\t</person:birthdate>\n</person:person>|
    assert doc({:person, %{Version: "1"}, [[{:birthdate, nil, [{:day, nil, "15"}, {:month, nil, "12"}, {:year, nil, "1515"}]}]]}, %{person: "person:", birthdate: ""}) == ~s|<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<person:person Version=\"1\">\n\t<birthdate>\n\t\t<day>15</day>\n\t\t<month>12</month>\n\t\t<year>1515</year>\n\t</birthdate>\n</person:person>|
    assert doc({:person, %{Version: "1"}, [[{:birthdate, nil, [{:day, nil, "15"}, {:month, nil, "12"}, {:year, nil, "1515"}]}]]}, %{person: "person:", birthdate: "", day: "day:"}) == ~s|<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<person:person Version=\"1\">\n\t<birthdate>\n\t\t<day:day>15</day:day>\n\t\t<month>12</month>\n\t\t<year>1515</year>\n\t</birthdate>\n</person:person>|
  end
  test "empty element" do
    assert doc(:person, []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person/>|
  end
  test "doc with content" do
    assert doc(:person, "Josh", []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person>Josh</person>|
  end
  test "doc with attributes" do
    assert doc(:person, %{occupation: "Developer", city: "Montreal"}, []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person city="Montreal" occupation="Developer"/>|
    assert doc(:person, %{}, []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person/>|
  end

  test "doc with attributes and content" do
    assert doc(:person, %{occupation: "Developer", city: "Montreal"}, "Josh", []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person city="Montreal" occupation="Developer">Josh</person>|
    assert doc(:person, %{occupation: "Developer", city: "Montreal"}, nil, []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person city="Montreal" occupation="Developer"/>|
    assert doc(:person, %{}, "Josh", []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person>Josh</person>|
    assert doc(:person, %{}, nil, []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person/>|
  end

  test "doc with children" do
    assert doc(:person, [{:name, %{id: 123}, "Josh"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person>\n\t<name id="123">Josh</name>\n</person>|
    assert doc(:person, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person>\n\t<first_name>Josh</first_name>\n\t<last_name>Nussbaum</last_name>\n</person>|
  end

  test "doc with attributes and children" do
    assert doc(:person, %{id: 123}, [{:name, "Josh"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person id="123">\n\t<name>Josh</name>\n</person>|
    assert doc(:person, %{id: 123}, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person id="123">\n\t<first_name>Josh</first_name>\n\t<last_name>Nussbaum</last_name>\n</person>|
  end

  test "doc children elements" do
    assert doc([{:name, %{id: 123}, "Josh"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<name id="123">Josh</name>|
    assert doc([{:first_name, "Josh"}, {:last_name, "Nussbaum"}], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<first_name>Josh</first_name>\n<last_name>Nussbaum</last_name>|
  end

  test "quoting and escaping attributes" do
    assert element(:person, %{height: 12}) == ~s|<person height="12"/>|
    assert element(:person, %{height: 12, weight: 120}) == ~s|<person height="12" weight="120"/>|
    assert element(:person, %{height: ~s|10'|}) == ~s|<person height="10'"/>|
    assert element(:person, %{height: ~s|10"|}) == ~s|<person height='10"'/>|
    assert element(:person, %{height: ~s|<10'5"|}) == ~s|<person height="&lt;10'5&quot;"/>|
  end

  test "escaping content" do
    assert element(:person, "Josh") == "<person>Josh</person>"
    assert element(:person, "<Josh>") == "<person>&lt;Josh&gt;</person>"
    assert element(:data, "1 <> 2 & 2 <> 3") == "<data>1 &lt;&gt; 2 &amp; 2 &lt;&gt; 3</data>"
  end

  test "wrap content inside cdata and skip escaping" do
    assert element(:person, {:cdata, "john & <is ok>"}) == "<person><![CDATA[john & <is ok>]]></person>"
  end

  test "multi level indentation" do
    assert doc([person: [first: "Josh", last: "Nussbaum"]], []) == ~s|<?xml version="1.0" encoding="UTF-8" ?>\n<person>\n\t<first>Josh</first>\n\t<last>Nussbaum</last>\n</person>|
  end

  def element(name, arg),
    do: XmlBuilderPlus.element(name, arg) |> XmlBuilderPlus.generate([])

  def element(name, attrs, content),
    do: XmlBuilderPlus.element(name, attrs, content) |> XmlBuilderPlus.generate([])
end
