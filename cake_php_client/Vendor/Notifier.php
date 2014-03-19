<?php
/**
 * Created by Webonise Lab.
 * User: Priyanka Bhoir <priyanka.bhoir@weboniselab.com>
 * Date: 8/11/13 3:02 PM
 */
require_once dirname(__FILE__) . '/Configuration.php';
class Notifier {
    protected $_apiKey = null;
    protected $_configuration = null;
    public static $instance = null;

    public function __construct($apiKey, $configOptions) {
        if (empty($apiKey)) {
            trigger_error('API key is necessary to getting started');
            exit;
        }
        $this->_configuration = new Configuration($apiKey, $configOptions);
        $this->_apiKey        = $apiKey;
    }

    public static function initiate($apiKey, $configOptions = array()) {
        $op = exec("node -v");
        if (empty($op)) {
            throw new Exception('Project106 : Node js is not installed');
            return;
        }
        if (empty(self::$instance)) {
            self::$instance = new self($apiKey, $configOptions);
        }

        return self::$instance;
    }

    public static function startNotifier($apiKey, $configOptions = array()) {
        self::initiate($apiKey, $configOptions);
        set_error_handler(array(self::$instance, 'notifyOnError'));
        set_exception_handler(array(self::$instance, 'notifyOnException'));

        return self::$instance;
    }


    public function notifyOnError($errorNo, $errorMessage, $errorFile, $errorLine, $errorContext) {


        if (empty($errorMessage)) {
            $errorMessage = 'Undefined error';
        }
        $backtrace = debug_backtrace();
        $backtrace = $this->filterBacktrace($backtrace);

        if (!empty($file) && !empty($line)) {
            array_unshift($backtrace, array('file' => $file, 'line' => $line));
        }
        $errorInformation = array(
            'message'          => $errorMessage,
            'backtrace'        => $backtrace,
            'error_controller' => '',
            'error_action'     => ''
        );
        $errorDetails     = $this->getErrorDetails($errorInformation);
        $jdata            = json_encode($errorDetails);

        if ($this->_configuration->_environment == 'production') {
            $string = dirname(__FILE__) . "/node_handler.js";
            exec("node " . $string . " '" . $jdata . "'");
        }

    }

    public function notifyOnException(Exception $e) {


        $errorMessage = $e->getMessage();

        $backtrace = $e->getTrace() ? : debug_backtrace();

        $backtrace = $this->filterBacktrace($backtrace);

        $file      = $e->getFile() ? $e->getFile() : '';
        $line      = $e->getLine() ? $e->getLine() : '';
        array_unshift($backtrace, array('file' => $file, 'line' => $line));

        $errorInformation = array(
            'message'          => $errorMessage,
            'backtrace'        => $backtrace,
            'error_controller' => '',
            'error_action'     => ''
        );
        $errorDetails     = $this->getErrorDetails($errorInformation);
        $jdata            = json_encode($errorDetails);

        if ($this->_configuration->_environment == 'production') {
            $string = dirname(__FILE__) . "/node_handler.js";
            exec("node " . $string . " '" . $jdata . "'");
        }

    }

    private function getErrorDetails($errorInformation) {

        $errorDetails              = array();
        $errorDetails['params']    = array('key' => 'value');
        $protocol                  = (isset($_SERVER['HTTPS']) ? 'https:' : 'http:');
        $errorDetails['url']       = $protocol . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
        $errorDetails['user_ip']   = $_SERVER['REMOTE_ADDR'];
        $errorDetails['headers']   = $_SERVER;
        $errorDetails['method']    = $_SERVER['REQUEST_METHOD'];
        $errorDetails['error']     = $errorInformation;
        $errorDetails['api_key']   = $this->_apiKey;
        $errorDetails['host_path'] = $this->_configuration->_hostPath;

        return $errorDetails;
    }

    private function filterBacktrace($backtrace) {
        $validFields = array(
            'file',
            'line',
            'function',
            'class'
        );
        $toReturn    = array();

        if (count($backtrace) > 1) {
            array_shift($backtrace);
        }
        foreach ($backtrace as $backtraceLevel) {
            $data = array();
            foreach ($backtraceLevel as $key => $value) {
                if (in_array($key, $validFields)) {
                    $data[$key] = $value;
                }
            }
            $toReturn[] = $data;
        }

        return ($toReturn);
    }
}
