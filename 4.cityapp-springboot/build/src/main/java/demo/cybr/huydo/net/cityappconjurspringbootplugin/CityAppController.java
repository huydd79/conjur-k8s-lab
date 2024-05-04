package demo.cybr.huydo.net.cityappconjurspringbootplugin;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CityAppController {
    @Autowired
    CityAppRepository cityRepo;

    @RequestMapping("/")
    public String home(Model model) {
        List <City> cities = cityRepo.getRandomCity();
        model.addAttribute("cities", cities);
        return "cityapp";
    }
}