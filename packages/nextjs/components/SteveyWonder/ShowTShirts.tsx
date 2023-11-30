import { ShowTShirt } from "./ShowTShirt";
import { Address } from "viem";
import { useScaffoldContract, useScaffoldContractRead } from "~~/hooks/scaffold-eth";

type Props = {
  tokenId: bigint;
};

export const ShowTShirts = ({ tokenId }: Props) => {
  const { data: AccountImpl } = useScaffoldContract({
    contractName: "Account",
  });

  const { data: SteveyWonder } = useScaffoldContract({
    contractName: "SteveyWonder",
  });

  const { data: tbaAddress } = useScaffoldContractRead({
    contractName: "ERC6551Registry",
    functionName: "account",
    args: [
      AccountImpl?.address,
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      BigInt(31337),
      SteveyWonder?.address,
      BigInt(tokenId),
    ],
  });

  const { data: balanceOfTShirt } = useScaffoldContractRead({
    contractName: "TShirt",
    functionName: "balanceOf",
    args: [tbaAddress],
  });

  const { data: TShirt } = useScaffoldContract({
    contractName: "TShirt",
  });

  const { data: activeTShirt } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "getActiveAccessory",
    args: [TShirt?.address, tokenId],
  });

  if (Number(balanceOfTShirt) === 0) {
    return <div>Nothing to show. Go to Accessories to mint.</div>;
  }

  const indexList = Array.from({ length: Number(balanceOfTShirt) }, (value, index) => index);

  if (Number(balanceOfTShirt) > 0) {
    return (
      <>
        {indexList.map((index, value) => {
          return (
            <div key={index}>
              <ShowTShirt index={value} tba={tbaAddress as Address} activeTShirt={Number(activeTShirt)} />
            </div>
          );
        })}
      </>
    );
  }

  return <></>;
};
