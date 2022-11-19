<!DOCTYPE html>
<?php
  $secrets_source="ENVIRONMENT";
  $db_addr=getenv('DBADDR');
  $db_user=getenv('DBUSER');
  $db_pass=getenv('DBPASS');
  $ccp_fqdn=getenv('CCPFQDN');
  $appid=getenv('APPID');
  $query=getenv('QUERY');
  if(!empty($db_addr))
  {
    $host=$db_addr;
    $user=$db_user;
    $pass=$db_pass;
  }
  elseif(file_exists('/conjur/worlddb.json'))
  {
    $secrets_source="FILE /conjur/worlddb.json";
    $json_data = file_get_contents('/conjur/worlddb.json');
    $response_data = json_decode($json_data);
    $host = $response_data->dbaddr;
    $user = $response_data->dbuser;
    $pass = $response_data->dbpass;
  }
  elseif(file_exists('/etc/secret-volume'))
  {
    $secrets_source="K8S SECRETS";
    $host = file_get_contents('/etc/secret-volume/dbaddr');
    $user = file_get_contents('/etc/secret-volume/dbuser');
    $pass = file_get_contents('/etc/secret-volume/dbpass');
  }
  elseif(!empty($ccp_fqdn))
  {
    $secrets_source="AIMWebService";
    $ccp_url='https://'.$ccp_fqdn.'/AIMWebService/api/Accounts?AppID='.$appid.'&'.$query;
    $opts = array(
      'ssl'=>array(
        'verify_peer'=>false,
        'verify_peer_name'=>false
      )
    );
    $context = stream_context_create($opts);
    $json_data = file_get_contents($ccp_url, false, $context);
    $response_data = json_decode($json_data);
    $host = $response_data->Address;
    $user = $response_data->UserName;
    $pass = $response_data->Content;
  }
  else
  {
    exit('<h1>No database credentials configured!</h1>');
  }
  $port = '3306';
  $data = 'world';
  $chrs = 'utf8mb4';
  $attr = "mysql:host=$host;port=$port;dbname=$data;charset=$chrs";
  $opts =
  [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
  ];
  try
  {
    $pdo = new PDO($attr, $user, $pass, $opts);
  
    $query = "SELECT city.Name as City,country.name as Country,city.District,city.Population FROM city,country WHERE city.CountryCode = country.Code ORDER BY RAND() LIMIT 0,1";
    $result = $pdo->query($query);
    $row = $result->fetch();
  
  }
  catch (PDOException $e)
  {
    $err_msg=$e->getMessage();
  }
  ?>
<html>
  <head>
    <link rel="icon" href="https://www.cyberark.com/wp-content/themes/understrap-child/favicon.ico">
    <title>CyberArk Demo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi" crossorigin="anonymous">
  </head>
  <body>
    <header>
      <div class="navbar navbar-dark bg-dark shadow-sm">
        <div class="container">
          <img src="https://docs.cyberark.com/Product-Doc/OnlineHelp/Portal/Content/Resources/_TopNav/Images/Skin/lg-cyberark.svg">
        </div>
      </div>
    </header>
    <main>
      <section class="py-3 text-center container">
        <div class="row py-lg-3">
          <div class="col-lg-12 col-md-12 mx-auto">
            <h1 class="fw-light">CyberArk Integration Demo</h1>
            <p class="lead">&nbsp</p>
            <h2 class="fw-light">Random World Cities!</h2>
            <h3 class="fw-light">
              <?php
                if(empty($err_msg)){ 
                  echo '<b>'.$row['City'].'</b> is a city in <b>'.$row['District'].'</b>, <b>'.$row['Country'].'</b> with a population of <b>'.$row['Population'].'</b>';
                }else {
                  echo '<b><font color=red>DB ERROR: '.$err_msg.'</b></font>';
                }
              ?>
            </h3>
            <p class="lead">&nbsp</p>
            <div class="bg-light p-3 rounded col-lg-5 col-md-5 mx-auto">
              <p class="lead">
                <?php
                  echo 'Host: <b>'.getenv('HOSTNAME').'</b>';
                ?>
              </p>
              <p class="lead">
                <?php
                  echo 'Secret source: <b>'.$secrets_source.'</b>';
                ?>
              </p>
              <p class="lead">
                <?php
                  echo 'Connected to database <b>'.$data .'</b> on <b>'.$host.'</b>:<b>'.$port.'</b>';
                ?>
              </p>
              <p class="lead">
                <?php
                  echo 'Using username: <b>'.$user.'</b> and password: <b>'.$pass.'</b>';
                ?>
              </p>
            </div>
            <p class="lead">&nbsp</p>
            <p>
              <a href="https://docs.cyberark.com" class="btn btn-primary my-2">CyberArk Docs</a>
              <a href="https://cyberark-customers.force.com/mplace/s/" class="btn btn-secondary my-2">CyberArk Marketplace</a>
            </p>
          </div>
        </div>
      </section>
    </main>
    <footer class="text-muted py-3">
      <div class="container">
        <p class="float-end mb-1">
          <a href="#">Back to top</a>
        </p>
        <p class="mb-1">A CyberArk demo by Joe Tan <a href="mailto:joe.tan@cyberark.com">✉</a></p>
        <p class="mb-1">Added push to k8s secret demo by Huy Do <a href="mailto:huy.do@cyberark.com">✉</a></p>
        <p class="mb-0">Style by <a href="https://getbootstrap.com/">Bootstrap</a>.</p>
      </div>
    </footer>
  </body>
</html>
