package demo.cybr.huydo.net.cityappconjurspringbootplugin;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class EnvController {

    @RequestMapping(value = "/env")
    public String hello(Model model) {
        return "env";
    }
}