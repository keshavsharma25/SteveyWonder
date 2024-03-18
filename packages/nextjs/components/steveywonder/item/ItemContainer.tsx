import { useEffect, useState } from "react";
import Link from "next/link";
import { Address } from "viem";
import { Item } from "~~/components/steveywonder/item/Item";
import { useBalanceOfOwner } from "~~/hooks/steveywonder/useBalanceOfOwner";
import { useTokenBoundAddress } from "~~/hooks/steveywonder/useTokenBoundAddress";
import { Option } from "~~/types/steveywonder";
import { cn } from "~~/utils/cn";
import { ContractName } from "~~/utils/scaffold-eth/contract";

type Props = {
  tokenId: number;
};

export const ItemContainer = ({ tokenId }: Props) => {
  const [option, setOption] = useState<Option>("TShirt");
  const options: Option[] = ["TShirt", "Pants", "Hairs", "Shoes", "Glasses"];

  const [isLoading, setIsLoading] = useState(false);

  const { tba } = useTokenBoundAddress(tokenId);

  const { addrBalance, status } = useBalanceOfOwner({
    address: tba,
    name: option as ContractName,
  });

  useEffect(() => {
    if (status === "loading") {
      setIsLoading(true);
    }

    if (status === "success") {
      setIsLoading(false);
    }
  }, [status]);

  useEffect(() => {
    console.log(status);
  }, [status]);

  return (
    <div className="flex flex-col h-full">
      <div className={"flex flex-row gap-8 items-end w-max h-11 px-2 mb-8"}>
        {options.map((item, key) => {
          return (
            <div
              key={key}
              className={cn(
                "cursor-pointer text-2xl text-[#717D96] font-medium leading-8 w-fit transition-all duration-200",
                option === item && "text-4xl text-white leading-10",
              )}
              onClick={() => {
                setOption(item);
              }}
            >
              {item}
            </div>
          );
        })}
      </div>
      <div className="h-full w-full overflow-y-scroll">
        {isLoading ? (
          <div className="flex justify-center items-center h-full w-full rounded-lg">
            <span className="loading loading-spinner loading-md"></span>
          </div>
        ) : addrBalance && addrBalance > 0 ? (
          <ItemCards tba={tba} option={option} addrBalance={addrBalance} tokenId={tokenId} />
        ) : (
          <GoToAccessories />
        )}
      </div>
    </div>
  );
};

type ItemCardsProps = {
  tba: Address | undefined;
  option: Option;
  addrBalance: bigint | undefined;
  tokenId: number;
};

const ItemCards = ({ tba, option, addrBalance, tokenId }: ItemCardsProps) => {
  return (
    <div className="flex flex-row flex-wrap gap-4">
      {Array.from({ length: Number(addrBalance) }, (_, index) => index).map(value => {
        return <Item key={value} idx={BigInt(value)} tba={tba} option={option} mainTokenId={tokenId} />;
      })}
    </div>
  );
};

const GoToAccessories = () => {
  return (
    <div className="flex justify-center items-center h-full w-full bg-gray-300 rounded-lg backdrop-blur-md bg-opacity-5">
      <Link className="bg-[#3C44FF] px-6 py-4 font-medium text-xl rounded-lg" href="/accessories">
        Go to Accessories
      </Link>
    </div>
  );
};
