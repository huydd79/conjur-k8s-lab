package demo.cybr.huydo.net.cityappconjurspringbootplugin;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import com.cyberark.conjur.sdk.endpoint.SecretsApi;
import com.cyberark.conjur.springboot.constant.ConjurConstant;
import com.cyberark.conjur.springboot.domain.ConjurProperties;

@Primary
@Configuration(proxyBeanMethods=false)
@ConfigurationProperties(prefix = "spring.datasource")
public class ConjurSpringDbConfig extends DataSourceProperties {
	private static final Logger logger = LoggerFactory.getLogger(ConjurSpringDbConfig.class);

	//Getting conjur variable paths from environment variables
	@Value ("${CONJUR_MAPPING_DB_HOST}")
	private String dbhost_var;
	@Value ("${CONJUR_MAPPING_DB_USER}")
	private String dbuser_var;
	@Value ("${CONJUR_MAPPING_DB_PASS}")
	private String dbpass_var;
	
	private final SecretsApi secretsApi = new SecretsApi();

    @Override
	public void afterPropertiesSet() throws Exception {
		super.afterPropertiesSet();
		
		if (!dbhost_var.isBlank() && !dbuser_var.isBlank() && !dbpass_var.isBlank() ) {
			String dbhost = secretsApi.getSecret("DEMO", ConjurConstant.CONJUR_KIND, new String(dbhost_var));
			String dbuser = secretsApi.getSecret("DEMO", ConjurConstant.CONJUR_KIND, new String(dbuser_var));
			String dbpass = secretsApi.getSecret("DEMO", ConjurConstant.CONJUR_KIND, new String(dbpass_var));
			
			//Replacing default host to value got from conjur
			String dburl = this.getUrl();
			dburl = dburl.replace(dburl.substring(dburl.indexOf("://"), dburl.indexOf(":", dburl.indexOf("://")+1)), "://" + dbhost);

			logger.info("DEMO: Got conjur variable mappings. Requesting screts from conjur... ");
			logger.info("=================> DEMO: CONJUR_MAPPING_DB_HOST: var=" + dbhost_var + "; value=" + dbhost);
			logger.info("=================> DEMO: CONJUR_MAPPING_DB_USER: var=" + dbuser_var + "; value=" + dbuser);
        		logger.info("=================> DEMO: CONJUR_MAPPING_DB_PASS: var=" + dbpass_var + "; value=" + dbpass);
			logger.info("=================> DEMO: UPDATED DB URL     : " + dburl);

			this.setUrl(dburl);
			this.setUsername(new String(dbuser));
			this.setPassword(new String(dbpass));
		} else {
			String dburl = this.getUrl();
			String dbuser = this.getUsername();
			String dbpass = this.getPassword();
			
			logger.info("DEMO: Conjur variable mapping is empty. Using default driver ");
			logger.info("=================> DEMO: DB_URL : var=" + dburl);
			logger.info("=================> DEMO: DB_USER: var=" + dbuser);
        	logger.info("=================> DEMO: DB_PASS: var=" + dbpass);
		}
	}
}
