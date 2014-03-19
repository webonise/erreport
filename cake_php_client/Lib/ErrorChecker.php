<?php
/**
 * Created by Webonise Lab.
 * User: Priyanka Bhoir <priyanka.bhoir@weboniselab.com>
 * Date: 8/11/13 2:30 PM
 */
//APP::import('Lib','notifier',array('file'=>'Notifier.php'));
require_once APP . 'Plugin/Erreport/Vendor/Notifier.php';
class ErrorChecker extends ErrorHandler {
    public static function  onError($errorNo, $errorMessage, $errorFile = null, $errorLine = null, $errorContext = null) {

        $start=memory_get_usage();
        $start_time=microtime(true);

        $apiKey        = Configure::read('apiKey');
        $configOptions = Configure::read('project106.options');
        $notifier      = Notifier::initiate($apiKey, $configOptions);
        if (!empty($notifier)) {
            $notifier->notifyOnError($errorNo, $errorMessage, $errorFile, $errorLine, $errorContext);
        }
        $end=memory_get_usage();
        $end_time=microtime(true);
        $mem=$end-$start;
        $time=$end_time-$start_time;
        error_log("\n project106 error :memory=$mem  time=$time",3,'/home/webonise/new.txt');

        parent::handleError($errorNo, $errorMessage, $errorFile, $errorLine, $errorContext);
    }

    public static function onException(Exception $e) {

        $start=memory_get_usage();
        $start_time=microtime(true);

        $apiKey        = Configure::read('apiKey');
        $configOptions = Configure::read('project106.options');
        $notifier      = Notifier::initiate($apiKey, $configOptions);
        if (!empty($notifier)) {
            $notifier->notifyOnException($e);
        }
        $end=memory_get_usage();
        $end_time=microtime(true);
        $mem=$end-$start;
        $time=$end_time-$start_time;
        error_log("\n project106 exception memory=$mem  time=$time",3,'/home/webonise/new.txt');

        parent::handleException($e);
    }
}