pipeline {
    agent { dockerfile true }
    stages {
        stage('Checkout SDK generator code') {
			steps {
				checkout(
					[$class: 'GitSCM', branches: [[name: '*/master']], 
					doGenerateSubmoduleConfigurations: false,
					extensions: [], 
					submoduleCfg: [], 
					userRemoteConfigs: [[url: 'https://github.com/krishnakumarkp/sdk_generator']]]
				)
			}
        }
        stage('Prepare') {
            steps {
                sh 'rm -rf build/api'
                sh 'rm -rf build/coverage'
                sh 'rm -rf build/logs'
                sh 'rm -rf build/pdepend'
                sh 'rm -rf build/sdk-repo'
                sh 'rm -rf build/sdk-php'
                sh 'mkdir build/api'
                sh 'mkdir build/coverage'
                sh 'mkdir build/logs'
                sh 'mkdir build/pdepend'
            }
        }
		stage('Install composer and dependencies') {
			steps {
				sh 'wget -q https://getcomposer.org/download/1.10.10/composer.phar'
				sh 'php composer.phar install --prefer-dist --no-progress'
            }
        }
		stage('Generate php sdk') {
			steps {
				sh 'bash generator.sh -s 20200905.141900'
            }
        }
		stage("PHPLint") {
			steps {
				sh 'find sdk-php -name "*.php" -print0 | xargs -0 -n1 php -l'
			}
		}
		stage('Checkstyle Report') {
			steps {
				script { 
					sh 'vendor/bin/phpcs --report=checkstyle --report-file=build/logs/checkstyle.xml --standard=PSR12 --extensions=php --ignore=autoload.php --ignore=vendor/ sdk-php || exit 0'
					def checkstyle = scanForIssues tool: checkStyle(pattern: 'build/logs/checkstyle.xml')
					publishIssues issues: [checkstyle]
				}
			}
		}
		stage('Mess Detection Report') {
			steps {
				script { 
					sh 'vendor/bin/phpmd sdk-php xml build/phpmd.xml --reportfile build/logs/pmd.xml --exclude vendor/ --exclude autoload.php || exit 0'
					def pmd = scanForIssues tool: pmdParser(pattern: 'build/logs/pmd.xml')
					publishIssues issues: [pmd]
				}
			}
			
		}
		stage('Software metrics') { 
			steps { 
				sh 'vendor/bin/pdepend --jdepend-xml=build/logs/jdepend.xml --jdepend-chart=build/pdepend/dependencies.svg --overview-pyramid=build/pdepend/overview-pyramid.svg --ignore=vendor sdk-php' 
			} 
		}
		stage('Push php sdk') {
			steps {
				sh 'bash git_push.sh -s 20200905.141900'
            }
        }
    }
}