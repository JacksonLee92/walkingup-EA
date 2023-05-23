# Expert-Advisor-for-Setup-Walking-up-the-Bands

Expert Advisors (experts) are programs in the terminal that have been developed in MetaQuotes Language (MQL) and used for automation of analytical and trading processes. 

Bollinger Bands are a type of technical indicator developed by John Bollinger in the 1980s for trading stocks. A Bollinger Band consists of a middle band (which is a moving average) and an upper and lower band. The bands come closer during low volatility and widen during high volatility. 

The setup or strategy named Walking up the bands consists in buy when the prices goes out from upper band due to high volatility. The sell happens when the prices goes out from lower band. The goal is get all the uptrend of asset. This strategy does not use stop loss. 

When this strategy must be used? When the prices are low and a new uptrend be initialized. Avoid it at the historical tops.

![walking up the band](https://user-images.githubusercontent.com/78765404/236300918-c0648970-d64c-4646-a920-96d4f78df592.png)
Fig. 1. Example of the trading using the strategy Walking up the bands. Blue arrow represents the buy and red arrow represents the sell.

![Limite_BBAS3_bands](https://user-images.githubusercontent.com/78765404/236837256-eeb4946e-e73c-4bc8-930b-bd578633655b.png)
Fig. 2. Example of choice of the limit for prices to avoid historical top of the asset.

On platform Metatrader 5, in inputs, at the part "Configurações operacionais" there are the option "Limite de preço para evitar o topo histórico" where it can be inserted the price limit. 

Anyone interested can fork and contribute with this code and usage strategies.

Disclaimer: This post contains no financial advice. Do your own research. Use at your own risk.
