Project-106
=============

CakePHP projects
================
Installation
=============
- You need to copy this folder to your application plugin folder
- Then

```php
cd <path-to-Plugin>/Erreport
sh installDependencies.sh
```

Configurations
====================

- app/Config/bootstrap.php

```php
CakePlugin::load('Erreport');
App::uses('ErrorChecker','Erreport.Lib');
```
- app/Config/core.php

```php
Configure::write('Error', array(
    'handler' => 'ErrorChecker::onError',
    'level' => E_ALL & ~E_DEPRECATED,
    'trace' => true
));

Configure::write('Exception', array(
    'handler' => 'ErrorChecker::onException',
    'renderer' => 'ExceptionRenderer',
    'log' => true
));
Configure::write('apiKey','<Your API-KEY >');

```

