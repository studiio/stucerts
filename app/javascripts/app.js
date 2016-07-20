var accounts;
var account;


function refreshBalance() {
  var meta = MetaCoin.deployed();

  meta.getBalance.call(account, {from: account}).then(function(value) {
    var balance_element = document.getElementById("balance");
    balance_element.innerHTML = value.valueOf();
  }).catch(function(e) {
    console.log(e);
    setStatus("Error getting balance; see log.");
  });
};

function sendCoin() {
  var meta = MetaCoin.deployed();

  var amount = parseInt(document.getElementById("amount").value);
  var receiver = document.getElementById("receiver").value;

  setStatus("Initiating transaction... (please wait)");

  meta.sendCoin(receiver, amount, {from: account}).then(function() {
    setStatus("Transaction complete!");
    refreshBalance();
  }).catch(function(e) {
    console.log(e);
    setStatus("Error sending coin; see log.");
  });
};

/**
 * Simple alert
 */
function showError(msg) {
  $('#main-alert-message').html(msg);
  $('#main-alert').show();
}

/**
 * Check each local certificate with the blockchain
 */
function checkCertsSync() {
  $('tr[data-cert-id]').each(function() {
    var id = $(this).data('cert-id');

    if(id) {
      checkCertSync(id);
    }
    else {
      $(this).find('.loading').hide();
      $(this).find('.not-in-blockchain').show();
    }
    
  });
}

/**
 * Check a local certificate with the blockchain
 */
function checkCertSync(id) {
  var stuCerts = StuCerts.deployed();
  var line = $('tr[data-cert-id="' + id + '"]');
  var loadingIndicator = line.find('.loading');
  var syncIndicator = line.find('.sync-blockchain');
  var notPresentIndicator = line.find('.not-in-blockchain');

  stuCerts.getCertificate(id).then(function(value) {
    loadingIndicator.hide();
    syncIndicator.show();
  }).catch(function(e) {
    loadingIndicator.hide();
    notPresentIndicator.show();
  });
}

/**
 * Setup behaviors
 */
function setupBehaviors() {
  var stuCerts = StuCerts.deployed();

  $('tr[data-cert-id]').each(function() {
    var row = $(this);
    var certFirstName = row.data('cert-first-name');
    var certLastName = row.data('cert-last-name');
    var certTrainingTitle = row.data('cert-training-title');
    var certTrainingDate = parseInt(row.data('cert-training-date'));
    var certTrainingDuration = parseInt(row.data('cert-training-duration'));

    // Add to blockchain button
    $(this).find('.add-to-blockchain').click(function() {
      $(this).attr('disabled', 'disabled');
      stuCerts.createCertificate(
        certFirstName,
        certLastName,
        certTrainingTitle,
        certTrainingDate,
        certTrainingDuration,
        {from: account}
      ).then(function(value) {

      }).catch(function(e) {
        showError("There was an error adding the certificate to Ethereum.");
        console.log(e);
      });
    });

  });
}


/**
 * Listen and reacts to the smart contract events
 */
function watchBlockchainEvents() {
  var stuCerts = StuCerts.deployed();
  
  // On certificate creation
  stuCerts.certificateCreated().watch(function(error, result){
    if (!error) {
      var tx = result.transactionHash;
      var certId = result.args.certId;

      // Fetch the row for which we were called (dirty, but we can't get a return 
      // value from transactions)
      stuCerts.getCertificate(certId).then(function(result) {
        var row = $('tr[data-cert-id=""][data-cert-first-name="' + result[0] + '"][data-cert-last-name="' + result[1] + '"][data-cert-training-title="' + result[2] + '"]');
        if(row.length >= 1) {
          row.attr('data-cert-id', certId);
          console.log(row);
          //TODO: AJAX call
        }
        else {
          showError("CertificateCreated event : There was an error processing the new certificate.");
        }
      });
    }
    else {
      showError("There was an error listening to Ethereum events.");
    }
  });
}



$(function() {

  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      showError("There was an error connecting to your local Ethereum client. Make sure your Ethereum client is on.");
      return;
    }

    if (accs.length == 0) {
      showError("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }

    accounts = accs;
    account = accounts[0];

    // Add behaviors to buttons
    setupBehaviors();

    // Watch blockchain events
    watchBlockchainEvents();

    // Check certs sync now
    checkCertsSync();
  });

});