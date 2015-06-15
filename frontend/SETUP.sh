
echo ""
echo "+++++++"
echo "Capisco (I Understand) Web Server Setup Instructions"
echo "+++++++"
echo ""

echo "+++"
echo "To install additions gems:"
echo "  bundle install --path vendor/bundle"
echo "+++"
echo ""

echo "+++"
echo "+To set up the databases:"
echo "+ ./bin/rake db:migrate"
echo "+++"
echo ""

echo "+++"
echo "Change the port and host values in:" 
echo "  app/helpers/knowledge_base_helper.rb"
echo "You may want to set the host to localhost, in order to access it locally"
echo "(You may want to change the port number too if your wmi instance is"
echo "running on a different port)"

echo "+++"
echo "To set up the ssh tunnel to the Capisco Telnet server on port 3434 ..."
echo "This might need to be done in two steps, if 'wmi' not directly accessable"
echo "e.g.,"
echo "  ssh -L 3434:localhost:3434 <cs-linux-machine>.cms.waikato.ac.nz"
echo "  ssh -L 3434:localhost:3434 wmi.cms.waikato.ac.nz"
echo "('wmi' is an alias for 'rautini')"
echo "+++"
echo ""

echo "+++"
echo "To start the server:"
echo "  rails server -p 2015"
echo "+++"
echo ""


