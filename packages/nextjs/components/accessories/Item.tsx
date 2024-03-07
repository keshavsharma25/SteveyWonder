import Image from "next/image";
import { MintAccs } from "./MintAccs";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  item: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry">;
  tokenId: bigint;
};

export const Item = ({ item, tokenId }: Props) => {
  return (
    <div className="w-[200px]">
      <div className="relative">
        <div className="w-full h-full">
          <Image src={`./accessories/${item}.png`} alt={item} fill />
        </div>
      </div>
      <div className="flex flex-row justify-between">
        <div>{item}</div>
        <div>
          <MintAccs contractName={item} name="Mint" tokenId={tokenId} />
        </div>
      </div>
    </div>
  );
};
