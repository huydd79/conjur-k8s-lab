package demo.cybr.huydo.net.cityappconjurspringbootplugin;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table (name = "city")
public class City
{
    @Id
    private String city;
    private String district;
    private String country;
    private Integer population;
    
    public City ()
    {
    }

    public City (String city, String country, String district, Integer population)
    {
        this.city = city;
        this.country = country;
        this.district = district;
        this.population = population;
    }

    public String ShowContent (){
        return "<b>" + city + "</b> is a city in <b>" + district + "</b>, <b>" + country + "</b> with population of <b>" + population + "</b>";
    }
}
