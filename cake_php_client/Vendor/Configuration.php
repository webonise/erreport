<?php
/**
 * Created by Webonise Lab.
 * User: Priyanka Bhoir <priyanka.bhoir@weboniselab.com>
 * Date: 22/11/13 10:22 AM
 */
class Configuration {
    public $_environment = 'production';
    public $_warning = true;
    public $_apikey = null;
    public $_hostPath = array(
        'host' => 'beta.erreport.io',
        'path' => '/api/v1/error_reports'
    );

    public function __construct($apikey, $options = array()) {
        if (!empty($apikey)) {
            $this->_apikey = $apikey;
            if (!empty($options)) {
                $this->_environment = isset($options['environment']) ? $options['environment'] : 'production';
                $this->_warning     = isset($options['warning']) ? $options['warning'] : true;
            }
        }
    }

}
