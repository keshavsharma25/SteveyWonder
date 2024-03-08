import { useState } from "react";
import Link from "next/link";
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

  const { tba } = useTokenBoundAddress(tokenId);

  const { balance } = useBalanceOfOwner({
    address: tba,
    name: option as ContractName,
  });

  return (
    <div className="flex flex-col h-full">
      <div className={"flex flex-row gap-8 items-end w-max h-11 px-2"}>
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
      <div className="pt-10 h-full">
        {Number(balance) > 0 ? (
          [...Array(Number(balance))].slice(1).map((index, key) => {
            return (
              <div key={key}>
                <Item index={index} tba={tba} option={option} />
              </div>
            );
          })
        ) : (
          <div className="flex justify-center items-center h-full w-full bg-gray-300 rounded-lg backdrop-blur-md bg-opacity-5">
            <Link className="bg-[#3C44FF] px-6 py-4 font-medium text-xl rounded-lg" href="/accessories">
              Go to Accessories
            </Link>
          </div>
        )}
      </div>
    </div>
  );
};
