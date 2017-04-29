<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
<h1>Hello Jerry!</h1>
<form action="">
User name:<br>
<input type="text" name="usr_name" value="">
<br>
Role:<br>
<select name="age">
  <option value="owner">Owner</option>
  <option value="customer">Customer</option>
</select>
<br>
Age:<br>
<input type="number" name="age" min="1" max="150">
<br>
State:<br>
<select name="state">
  <option value="ca">CA</option>
  <option value="nv">NV</option>
  <option value="oh">OH</option>
</select>
<br><br>
<input type="submit" value="Signup">
</body>
</html>