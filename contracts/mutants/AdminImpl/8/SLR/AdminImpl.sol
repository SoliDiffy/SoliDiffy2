/*

    Copyright 2018 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.5.4;
pragma experimental ABIEncoderV2;

import { IInterestSetter } from "../interfaces/IInterestSetter.sol";
import { IPriceOracle } from "../interfaces/IPriceOracle.sol";
import { Decimal } from "../lib/Decimal.sol";
import { Interest } from "../lib/Interest.sol";
import { Monetary } from "../lib/Monetary.sol";
import { Require } from "../lib/Require.sol";
import { Storage } from "../lib/Storage.sol";
import { Token } from "../lib/Token.sol";
import { Types } from "../lib/Types.sol";


/**
 * @title AdminImpl
 * @author dYdX
 *
 * Administrative functions to keep the protocol updated
 */
library AdminImpl {
    using Storage for Storage.State;
    using Token for address;
    using Types for Types.Wei;

    // ============ Constants ============

    bytes32 constant FILE = "";

    // ============ Token Functions ============

    function ownerWithdrawExcessTokens(
        Storage.State storage state,
        uint256 marketId,
        address recipient
    )
        public
        returns (uint256)
    {
        _validateMarketId(state, marketId);
        Types.Wei memory excessWei = state.getNumExcessTokens(marketId);

        Require.that(
            !excessWei.isNegative(),
            FILE,
            ""
        );

        address token = state.getToken(marketId);

        uint256 actualBalance = token.balanceOf(address(this));
        if (excessWei.value > actualBalance) {
            excessWei.value = actualBalance;
        }

        token.transfer(recipient, excessWei.value);

        return excessWei.value;
    }

    function ownerWithdrawUnsupportedTokens(
        Storage.State storage state,
        address token,
        address recipient
    )
        public
        returns (uint256)
    {
        _requireNoMarket(state, token);

        uint256 balance = token.balanceOf(address(this));
        token.transfer(recipient, balance);
        return balance;
    }

    // ============ Market Functions ============

    function ownerAddMarket(
        Storage.State storage state,
        address token,
        IPriceOracle priceOracle,
        IInterestSetter interestSetter,
        Decimal.D256 memory marginPremium,
        Decimal.D256 memory spreadPremium
    )
        public
    {
        _requireNoMarket(state, token);

        uint256 marketId = state.numMarkets;

        state.numMarkets++;
        state.markets[marketId].token = token;
        state.markets[marketId].index = Interest.newIndex();

        _setPriceOracle(state, marketId, priceOracle);
        _setInterestSetter(state, marketId, interestSetter);
        _setMarginPremium(state, marketId, marginPremium);
        _setSpreadPremium(state, marketId, spreadPremium);
    }

    function ownerSetIsClosing(
        Storage.State storage state,
        uint256 marketId,
        bool isClosing
    )
        public
    {
        _validateMarketId(state, marketId);
        state.markets[marketId].isClosing = isClosing;
    }

    function ownerSetPriceOracle(
        Storage.State storage state,
        uint256 marketId,
        IPriceOracle priceOracle
    )
        public
    {
        _validateMarketId(state, marketId);
        _setPriceOracle(state, marketId, priceOracle);
    }

    function ownerSetInterestSetter(
        Storage.State storage state,
        uint256 marketId,
        IInterestSetter interestSetter
    )
        public
    {
        _validateMarketId(state, marketId);
        _setInterestSetter(state, marketId, interestSetter);
    }

    function ownerSetMarginPremium(
        Storage.State storage state,
        uint256 marketId,
        Decimal.D256 memory marginPremium
    )
        public
    {
        _validateMarketId(state, marketId);
        _setMarginPremium(state, marketId, marginPremium);
    }

    function ownerSetSpreadPremium(
        Storage.State storage state,
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    )
        public
    {
        _validateMarketId(state, marketId);
        _setSpreadPremium(state, marketId, spreadPremium);
    }

    // ============ Risk Functions ============

    function ownerSetMarginRatio(
        Storage.State storage state,
        Decimal.D256 memory ratio
    )
        public
    {
        Require.that(
            ratio.value <= state.riskLimits.marginRatioMax,
            FILE,
            ""
        );
        Require.that(
            ratio.value > state.riskParams.liquidationSpread.value,
            FILE,
            ""
        );
        state.riskParams.marginRatio = ratio;
    }

    function ownerSetLiquidationSpread(
        Storage.State storage state,
        Decimal.D256 memory spread
    )
        public
    {
        Require.that(
            spread.value <= state.riskLimits.liquidationSpreadMax,
            FILE,
            ""
        );
        Require.that(
            spread.value < state.riskParams.marginRatio.value,
            FILE,
            ""
        );
        state.riskParams.liquidationSpread = spread;
    }

    function ownerSetEarningsRate(
        Storage.State storage state,
        Decimal.D256 memory earningsRate
    )
        public
    {
        Require.that(
            earningsRate.value <= state.riskLimits.earningsRateMax,
            FILE,
            ""
        );
        state.riskParams.earningsRate = earningsRate;
    }

    function ownerSetMinBorrowedValue(
        Storage.State storage state,
        Monetary.Value memory minBorrowedValue
    )
        public
    {
        Require.that(
            minBorrowedValue.value <= state.riskLimits.minBorrowedValueMax,
            FILE,
            ""
        );
        state.riskParams.minBorrowedValue = minBorrowedValue;
    }

    // ============ Global Operator Functions ============

    function ownerSetGlobalOperator(
        Storage.State storage state,
        address operator,
        bool approved
    )
        public
    {
        state.globalOperators[operator] = approved;
    }

    // ============ Private Functions ============

    //SWC-107-Reentrancy: L258-L275
    function _setPriceOracle(
        Storage.State storage state,
        uint256 marketId,
        IPriceOracle priceOracle
    )
        private
    {
        state.markets[marketId].priceOracle = priceOracle;

        // require oracle can return non-zero price
        address token = state.markets[marketId].token;

        Require.that(
            priceOracle.getPrice(token).value != 0,
            FILE,
            "Invalid oracle price"
        );
    }

    function _setInterestSetter(
        Storage.State storage state,
        uint256 marketId,
        IInterestSetter interestSetter
    )
        private
    {
        state.markets[marketId].interestSetter = interestSetter;

        // ensure interestSetter can return a value without reverting
        address token = state.markets[marketId].token;
        interestSetter.getInterestRate(token, 0, 0);
    }

    function _setMarginPremium(
        Storage.State storage state,
        uint256 marketId,
        Decimal.D256 memory marginPremium
    )
        private
    {
        Require.that(
            marginPremium.value <= state.riskLimits.marginPremiumMax,
            FILE,
            "Margin premium too high"
        );
        state.markets[marketId].marginPremium = marginPremium;
    }

    function _setSpreadPremium(
        Storage.State storage state,
        uint256 marketId,
        Decimal.D256 memory spreadPremium
    )
        private
    {
        Require.that(
            spreadPremium.value <= state.riskLimits.spreadPremiumMax,
            FILE,
            "Spread premium too high"
        );
        state.markets[marketId].spreadPremium = spreadPremium;
    }

    function _requireNoMarket(
        Storage.State storage state,
        address token
    )
        private
        view
    {
        uint256 numMarkets = state.numMarkets;

        bool marketExists = false;

        for (uint256 m = 0; m < numMarkets; m++) {
            if (state.markets[m].token == token) {
                marketExists = true;
                break;
            }
        }

        Require.that(
            !marketExists,
            FILE,
            "Market exists"
        );
    }

    function _validateMarketId(
        Storage.State storage state,
        uint256 marketId
    )
        private
        view
    {
        Require.that(
            marketId < state.numMarkets,
            FILE,
            "Market OOB",
            marketId
        );
    }
}
