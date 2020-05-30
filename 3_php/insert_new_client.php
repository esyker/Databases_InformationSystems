<html>
	<body>
	<a href="insert_client_info.php">Home</a>
<?php
	$host = "db.tecnico.ulisboa.pt";
	$user = "ist186980";
	$pass = "tcsa6810";
	$dsn = "mysql:host=$host;dbname=$user";
	try
	{
		$connection = new PDO($dsn, $user, $pass);
	}
	catch(PDOException $exception)
	{
		echo("<p>Error: ");
		echo($exception->getMessage());
		echo("</p>");
		exit();
	}
	$VAT = $_REQUEST['VAT'];
	$name = $_REQUEST['name'];
	$birth_date = date('Y-m-d',strtotime($_REQUEST['birth_date']));
	$street = $_REQUEST['street'];
	$city = $_REQUEST['city'];
	$zip = $_REQUEST['zip'];
	$gender = $_REQUEST['gender'];
	$phone_number = $_REQUEST['phone_number'];
	
	#calculate age from birth date
	$birthDate = strtotime($_REQUEST['birth_date']);
	$age = (date("md", $birthDate)) > date("md")
    ? ((date("Y") - date('Y',$birthDate)) - 1)
    : (date("Y") - date('Y',$birthDate));
	
	if($VAT == '' || $VAT == NULL)
	{
		echo("<p>Error: VAT must not be empty</p>");
		exit();
	}
	if($name == '' || $name == NULL)
	{
		echo("<p>Error: Name must not be empty</p>");
		exit();
	}
	if($birth_date == '' || $birth_date == NULL)
	{
		echo("<p>Error: Birth Date must not be empty</p>");
		exit();
	}
	if($gender != 'Male' && $gender != 'Female')
	{
		echo("<p>Error: Gender must be either 'Male' or 'Female'</p>");
		exit();
	}
	
	
	$sql = $connection->prepare("INSERT INTO client VALUES (:VAT, :name, :birth_date, :street, :city, :zip, :gender, :age)");
	$sql->bindValue(':VAT', "$VAT");
	$sql->bindValue(':name', "$name");
	$sql->bindValue(':birth_date', $birth_date);
	$sql->bindValue(':street', "$street");
	$sql->bindValue(':city', "$city");
	$sql->bindValue(':zip', "$zip");
	$sql->bindValue(':gender', "$gender");
	$sql->bindValue(':age', $age);
	$sql->execute();
	
	$nrows=$sql->rowCount();
	if($nrows == 1)
		echo("<p>Client inserted successfully</p>");
	else if($nrows == 0)
	{
		echo("<p>Error: Client not inserted</p>");
		$connection = null;
		exit();
	}
	
	if($phone_number != '' && $phone_number != NULL)
	{
		$sql = $connection->prepare("INSERT INTO phone_number_client VALUES (:VAT, :phone_number)");
		$sql->bindValue(':VAT', "$VAT");
		$sql->bindValue(':phone_number', "$phone_number");
		$sql->execute();
	
		$nrows=$sql->rowCount();
		if($nrows == 1)
			echo("<p>Phone number inserted successfully</p>");
		else if($nrows == 0)
		{
			echo("<p>Error: Phone number not inserted</p>");
		}
	}
	
	
	
	$connection = null;
?>
	</body>
</html>
