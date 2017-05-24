<?php

$data = "This is some text I want to encrypt";
$method = "aes-256-cbc";
$password = "This is a really long key and su";
$options = 0;
$iv = "MMMMMMMMMMMMMMMM";

echo openssl_encrypt($data, $method, $password, $options, $iv)."\n";

$method = "aes-256-cfb";

echo openssl_encrypt($data, $method, $password, $options, $iv)."\n";

$method = "aes-256-ctr";

echo openssl_encrypt($data, $method, $password, $options, $iv)."\n";
