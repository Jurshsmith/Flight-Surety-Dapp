
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';
import { FlightStatusQueueMap } from './shared';


const heap = {};

const contract = new Contract('localhost', () => {
    // Read transaction
    contract.isOperational((error, result) => {
        console.log(error, result);
        display('Operational Status', 'Check if contract is operational', [{ label: 'Operational Status', error: error, value: result }]);
    });


    DOM.elid('participate-airline').addEventListener('click', async (e) => {
        const result = await contract.payAirlineSeedFunding().catch(_e => alert(_e));
        result && alert('Participation successful');
        e.stopPropagation();
    });

    // Create flight
    DOM.elid('create-flight').addEventListener('click', async (e) => {
        const flightName = DOM.elid('flight-name').value;
        // Write transaction
        try {
            await contract.registerFlight(contract.web3.utils.fromAscii(flightName));
            alert("Flight Registration is Successful");
        }
        catch (_e) {
            alert(_e);
        }
    });

    const _populateSelectElementWithFlights = (selectElement, flights) => {
        selectElement.innerHTML = '<option value="nil" id="no-option">--No Flight--</option>';
        flights.forEach((flight, i) => {
            const flightName = contract.web3.utils.hexToAscii(flight.flightName);

            selectElement.insertAdjacentHTML('beforeend', `<option value="${i}">${flightName}</option>`);
        });
    }

    DOM.elid('fetch-available-flights').addEventListener('click', async () => {
        const response = await fetch('http://localhost:3000/api/flights');
        const { flights } = await response.json();

        console.log("Available flights are ", flights);
        heap.flights = flights;

        _populateSelectElementWithFlights(DOM.elid('flight-options'), flights);
        _populateSelectElementWithFlights(DOM.elid('flight-key-options'), flights);

    });

    DOM.elid('flight-options').addEventListener('change', async (e) => {
        heap.selectedFlight = heap.flights?.[e.target.value];

        console.log({ selectedFlight: heap.selectedFlight });
    });

    DOM.elid('flight-key-options').addEventListener('change', async (e) => {
        heap.selectedFlightKey = heap.flights?.[e.target.value];

        console.log({ selectedFlightKey: heap.selectedFlightKey });
    });

    DOM.elid('submit-picked-flight').addEventListener('click', async () => {
        try {
            if (heap?.selectedFlight) {
                const valueToInsure = DOM.elid('passenger-flight-value-to-insure').value;
                const response = await contract.insureFlightForPassenger(heap?.selectedFlight?.flightKey, valueToInsure);

                if (response?.length > 0) {
                    alert("You have successfully insured your flight");
                }
            } else {
                alert("You have to pick a flight");
            }

        } catch (e) {
            alert(e);
        }

    });


    DOM.elid('fetch-flight-status').addEventListener('click', async () => {

        if (heap?.selectedFlightKey) {
            // Write transaction
            let error;
            await contract.fetchFlightStatus(heap?.selectedFlightKey?.flightKey).catch(e => {
                alert(e);
                error = e;
            });

            FlightStatusQueueMap[heap?.selectedFlightKey?.flightKey] = true;

        } else {
            alert("You have to pick a flight");
        }
    });

    DOM.elid('check-balance').addEventListener('click', async () => {
        try {
            const balance = await contract.checkMyBalance();
            console.log({ balance })
            alert(`Your balance is ${balance} ETH`);
        }
        catch (_e) {
            alert(_e);
        }
    });

    DOM.elid('cash-out').addEventListener('click', async () => {
        const cashOutValue = DOM.elid('cash-out-value').value;

        console.log({ cashOutValue });

        try {
            const response = await contract.withdrawFromBalance(cashOutValue);
            console.log({ response, cashOutValue });
            alert("Payout successful");
        }
        catch (_e) {
            alert(_e);
        }
    });



});



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