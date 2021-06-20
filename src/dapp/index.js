
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';



(async () => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error, result);
            display('Operational Status', 'Check if contract is operational', [{ label: 'Operational Status', error: error, value: result }]);
        });


        // User-submitted transaction
        // DOM.elid('submit-oracle').addEventListener('click', () => {
        //     let flight = DOM.elid('flight-number').value;
        //     // Write transaction
        //     contract.fetchFlightStatus(flight, (error, result) => {
        //         display('Oracles', 'Trigger oracles', [{ label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp }]);
        //     });
        // });


        DOM.elid('participate-airline').addEventListener('click', async () => {
            const result = await contract.payAirlineSeedFunding();
            result && alert('Participation successful');
        });

        // Create flight
        DOM.elid('create-flight').addEventListener('click', async (e) => {
            const flightName = DOM.elid('flight-name').value;
            // Write transaction
            console.log({ contract });

            console.log('hexewe', contract.web3.utils.asciiToHex(flightName));
            console.log('hexewe', contract.web3.utils.fromAscii(flightName));

            const k = await contract.registerFlight(contract.web3.utils.fromAscii(flightName));

            console.log({ k })
            e.stopPropagation();
        });

        DOM.elid('participate-airline').addEventListener('click', async () => {
            const result = await contract.payAirlineSeedFunding();
            result && alert('Participation successful');
        });

    });


})();


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({ className: 'row' }));
        row.appendChild(DOM.div({ className: 'col-sm-4 field' }, result.label));
        row.appendChild(DOM.div({ className: 'col-sm-8 field-value' }, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);
}







