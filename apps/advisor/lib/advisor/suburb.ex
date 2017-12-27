defmodule Advisor.Suburb do
  use HTTPoison.Base

  def process_url(url) do
    "http://api.geonames.org" <> url
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.fetch!("postalCodes")
    |> Enum.map( &Map.take(&1, ["adminCode1", "postalCode", "placeName", "lat", "lng"] ))
  end

  def find_suburbs(message, state) do
    cond do
      String.match?(message, ~r/^\d{4}$/) -> find_by_postcode(message)
      true -> find_by_name(message, state)
    end
  end

  defp find_by_postcode(code) do
    get!("/postalCodeSearchJSON?postalcode=#{code}&username=harrytest&country=AU").body 
  end

  defp find_by_name(name, state) do
    get!("/postalCodeSearchJSON?placename=#{name}&username=harrytest&country=AU").body
    |> Enum.filter(
      &(Map.fetch!(&1, "adminCode1") == String.upcase(state) &&
        (Map.fetch!(&1, "placeName") |> String.downcase) == name)
    )
  end
end