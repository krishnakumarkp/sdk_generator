
def abort_pipeline(param){ 
	currentBuild.result = 'ABORTED' 
	error(param + ' is required.') 
} 

pipeline {
    agent { 
		docker{
			image 'krishnakumarkp/sdk-gen'
		}
	}
    stages {
        stage('Check Params') {
			steps {
				script{
					
					//Swagger version is required for local to tag generated sdk. For REMOTE, if SWAGGER_VERSION is not provided, it will be derived from latest tag. 
					if ("${params.SWAGGER_VERSION}".isEmpty() && "${params.SWAGGER_FILE}" == "LOCAL") { 
						abort_pipeline("SWAGGER_VERSION") 
					} 
				}
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
				sh 'composer install --prefer-dist --no-progress'
            }
        }
		stage('Add known keys') {
			steps {
				sh """
				
					ssh-keyscan github.com >> /home/jenkins/.ssh/known_hosts
				"""
            }
        }
		stage('Generate php sdk') {
			steps {
				sshagent(['jenkinsuser']) {
					sh 'bash generator.sh -s "$SWAGGER_VERSION"'
				}
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
		stage('SonarTests') {
			steps { 
				sh 'sonar-scanner'
			}
		}
		stage('Push php sdk') {
			steps {
				sshagent(['jenkinsuser']) {
					sh """
				
						git config --global user.email "jenkins@jenkins.com"
						git config --global user.name "jenkin"
						bash git_push.sh -s "$SWAGGER_VERSION"
					"""
				}	
            }
        }
    }
}